@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezNoteEvent.ck", "ezPreviewInst.ck", "ezInstrument.ck"}

public class ezScorePlayer
{
    // data structures
    ezScore score;
    ezPart parts[];
    NoteEvent nextNotes[];
    ezInstrument instruments[];
    // int voice_to_midi[][];       // "voice" - an individual ugen in the overall voice array a voice
    //                              // -1 if voice is not in use (free), otherwise has the current midi pitch number it is being used for

    int voice_in_use[][];

    // parameters
    1::ms => dur tick;
    1 => float rate;
    false => int loop;

    // playback
    tick => dur tatum;
    dur playhead;
    false => int playing;
    dur end_of_score;

    fun ezScorePlayer() {}

    fun ezScorePlayer(ezScore s)
    {
        setScore(s);
    }

    fun void setScore(ezScore s)
    {
        if (playing) stop();
        
        s @=> score;
        s.parts @=> parts;
        <<<parts.size(), "parts processed">>>;
        // create note events for broadcasting (might not need this)
        new NoteEvent[score.numParts()] @=> nextNotes;

        // create instruments
        new ezInstrument[score.numParts()] @=> instruments;

        // keep track of which voices are currently in use
        new int[parts.size()][0] @=> voice_in_use;

        // remember the end position of the score
        setEnd(-1);
    }

    fun void setEnd(float beat)
    {
        if (beat > score.getScoreEnd())
        {
            <<< "ezScorePlayer: setScoreEnd() - provided beat is after the score end. beat:", beat, "| score end:", score.getScoreEnd() >>>;
            return;
        }
        if (beat == -1)
        {
            score.getScoreEnd() => beat;
        }
        (beat * 60000 / score.bpm)::ms => end_of_score;     // convert to dur, so playhead can be compared to it
    }

    // fun void setStart(float beat)
    // {
    //     if (beat < 0)
    //     {
    //         return;
    //     }
    //     (beat * 60000 / score.bpm)::ms => start_of_score;
    // }

    fun void play()
    {
        <<< "ezScorePlayer: play()" >>>;
        if (!playing)
        {
            true => playing;
            spork ~ tickDriver();
        }
    }

    fun void pause()
    {
        <<< "ezScorePlayer: pause()" >>>;
        false => playing;
        flushNotes();
    }

    fun void stop()
    {
        <<< "ezScorePlayer: stop()" >>>;
        false => playing;

        pos(0);
    }

    fun void tickDriver()
    {
        // 5::second => now;   // DELETE THIS
        while (playing)
        {
            if (playhead > end_of_score)
            {
                if (loop) pos(0);
                else stop();
            }
            
            for(int i; i < parts.size(); i++)
            {
                getNotesAtPlayhead(i);
            }

            // <<< playhead/ms >>>;
            tick * rate => tatum;
            tatum +=> playhead;
            tick => now;
        }


    }

    fun void pos(dur timePosition)
    {
        flushNotes();
        <<<"moving playhead to position (ms):", timePosition/ms>>>;
        timePosition => playhead;
    }

    fun void pos(float beatPosition)
    {
        flushNotes();
        <<<"moving playhead to position (beats):", beatPosition>>>;
        60000 / score.bpm => float ms_per_beat;
        ms_per_beat * (4 / score.time_sig_denominator) => ms_per_beat;
        (beatPosition * ms_per_beat)::ms => playhead;
    }

    fun void pos(int measures, float beats)
    {
        flushNotes();
        <<<"moving playhead to position (measure, beats):", measures, beats>>>;
        60000 / score.bpm => float ms_per_beat;
        (measures * (ms_per_beat * score.time_sig_numerator * (4 / score.time_sig_denominator)) + beats * ms_per_beat)::ms => playhead;
    }

    fun void flushNotes()
    {
        for(int part; part < parts.size(); part++)
        {
            for(int voice; voice < instruments[part].n_voices; voice++)
            {
                release_voice(part, voice);
            }
        }
    }

    fun void setInstrument(int partIndex, ezInstrument @ instrument)
    {
        instrument @=> instruments[partIndex];
        
        // keep track of which voices are currently in use
        new int[instrument.n_voices] @=> voice_in_use[partIndex];
    }

    fun void setInstrument(ezInstrument @ insts[])
    {
        if (insts.size() != parts.size())
        {
            <<< "ezScorePlayer: setInstrument() - provided instrument array size does not match the number of parts. size:", insts.size(), "| parts size:", parts.size() >>>;
            return;
        }

        for(int i; i < insts.size(); i++)
        {
            setInstrument(i, insts[i]);
        }
    }

    fun void getNotesAtPlayhead(int partIndex)
    {
        parts[partIndex] @=> ezPart thePart;
        60000 / score.bpm => float ms_per_beat;

        ezNote currentNotes[0];

        for(int i; i < thePart.measures.size(); i++)
        {
            thePart.measures[i] @=> ezMeasure theMeasure;

            for(int j; j < theMeasure.notes.size(); j++)
            {
                theMeasure.onset * ms_per_beat => float theMeasure_onset;

                theMeasure.notes[j] @=> ezNote theNote;
                theMeasure_onset + theNote.onset * ms_per_beat => float theNote_onset;
                
                if(Math.fabs(theNote_onset - playhead/ms) <= Math.fabs(tatum/ms)/2.0)        // take abs of tatum too!!!
                {
                    currentNotes << theNote;
                }
            }
        }
        if(currentNotes.size() > 0)
        {
            // <<< "playing", currentNotes.size(), "note(s) at time", playhead/ms >>>;
            currentNotes @=> nextNotes[partIndex].notes;
            // <<< "current notes size:", currentNotes.size()>>>;
            for(int i; i < currentNotes.size(); i++)
            {
                spork ~ playNoteWrapper(partIndex, currentNotes[i]);
            }
            //nextNotes[partIndex].broadcast();
        }
    }

    fun void playNoteWrapper(int partIndex, ezNote theNote)
    {
        allocate_voice(partIndex, theNote) => int voice_index;
        instruments[partIndex].noteOn(theNote, voice_index);

        chout <= "playing note " <= theNote.pitch <= " on voice " <= voice_index <= " for part " <= partIndex <= " at time " <= playhead/ms <= "ms," <= " at beat onset " <= theNote.onset <= " for " <= theNote.beats <= " beats, with velocity " <= theNote.velocity <= IO.newline();

        playhead/ms => float onset_ms;
        60000 / score.bpm => float ms_per_beat;
        theNote.beats * ms_per_beat => float duration_ms;
        Math.sgn(rate) => float direction;

        while((playhead/ms - onset_ms)*direction < duration_ms) 
        {
            tick => now;
        }

        release_voice(partIndex, voice_index);
    }

    // Allocates a new voice for the note and returns the index. 
    fun int allocate_voice(int partIndex, ezNote theNote)
    {
        // Get the first available voice for the note
        get_free_voice(partIndex) => int new_voice_index;

        // If there are no free voices, steal one
        if (new_voice_index == -1)
        {
            steal_voice(partIndex) => new_voice_index;
        }

        // Mark the voice as in use
        true => voice_in_use[partIndex][new_voice_index];
        
        return new_voice_index;
    }

    // Helper for allocate_voice(). Returns the lowest index of a free voice for a given part (or random index if there are no free voices).
    fun int get_free_voice(int partIndex)
    {
        instruments[partIndex].n_voices => int n_voices;
        for (int i; i < n_voices; i++) {
            if (!voice_in_use[partIndex][i])       // if voice i is free
            {
                return i;
            }
        }
        // if none are free return -1
        return -1;
    }

    // Helper for allocate_voice(). Steals a random voice and returns its index
    fun int steal_voice(int partIndex)
    {
        Math.random2(0, instruments[partIndex].n_voices - 1) => int stolen_voice_index;
        release_voice(partIndex, stolen_voice_index);
        return stolen_voice_index;
    }

    // Releases the voice that was in use for a specific note
    fun void release_voice(int partIndex, int voice_index)
    {
        if (voice_in_use[partIndex][voice_index])
        {
            instruments[partIndex].noteOff(voice_index);
            false => voice_in_use[partIndex][voice_index];
        }
    }

    fun void preview()
    {
        // new defaultVoice[parts.size()] @=> instruments;
        for(int i; i < parts.size(); i++)
        {
            defaultVoice tempVoice;
            setInstrument(i, tempVoice);
            // instruments[i] => previewGain;
        }
        pos(0.0);
        play();
        // previewGain.gain(1.0);
        // spork ~ tickDriver();
    }

}

