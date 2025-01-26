@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezNoteEvent.ck", "ezDefaultInst.ck", "ezInstrument.ck"}

public class ezScorePlayer
{
    // public member variables
    ezScore score;
    ezPart parts[];
    ezInstrument instruments[];
    Gain previewGain => dac;

    false => int loop;
    1 => float rate;
    false => int log_playback;

    // private member variables
    1::ms => dur tick;
    tick => dur tatum;
    dur previous_playhead;
    dur playhead;
    
    false => int playing;
    dur start_of_score;
    dur end_of_score;
    int voice_in_use[][];
    Event tick_driver_end;

    // Preview
    ezDefaultInst previewInsts[];

    // Constructors
    fun ezScorePlayer() {}

    fun ezScorePlayer(ezScore s)
    {
        setScore(s);
    }

    // Public functions
    fun void setScore(ezScore s)
    {
        if (playing) stop();
        
        s @=> score;
        s.parts @=> parts;
        // <<<parts.size(), "parts processed">>>;

        // create instruments
        new ezInstrument[score.numParts()] @=> instruments;

        // create preview instrument
        new ezDefaultInst[score.numParts()] @=> previewInsts;
        for(int i; i < score.numParts(); i++)
        {
            ezDefaultInst tempInst;
            tempInst @=> previewInsts[i];
        }

        // keep track of which voices are currently in use
        new int[parts.size()][0] @=> voice_in_use;

        // remember the end position of the score
        setEnd(-1);
    }

    fun void setInstrument(int partIndex, ezInstrument @ instrument)
    {
        instrument @=> instruments[partIndex];
        
        // keep track of which voices are currently in use
        new int[instrument._n_voices] @=> voice_in_use[partIndex];
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

    fun void preview()
    {
        setInstrument(previewInsts);
        play();
    }

    fun void play()
    {
        // <<< "ezScorePlayer: play()" >>>;
        if (!playing)
        {
            true => playing;
            spork ~ tickDriver();
        }
    }

    fun void pause()
    {
        // <<< "ezScorePlayer: pause()" >>>;
        false => playing;
        tick_driver_end => now;
        flushNotes();
    }

    fun void stop()
    {
        // <<< "ezScorePlayer: stop()" >>>;
        false => playing;
        spork ~ stop_listener();
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

    fun void pos(dur timePosition)
    {
        flushNotes();
        // <<<"moving playhead to position (ms):", timePosition/ms>>>;
        timePosition => playhead;
        playhead => previous_playhead;
    }

    fun void pos(float beatPosition)
    {
        flushNotes();
        // <<<"moving playhead to position (beats):", beatPosition>>>;
        60000 / score.bpm => float ms_per_beat;
        ms_per_beat * (4 / score.time_sig_denominator) => ms_per_beat;
        (beatPosition * ms_per_beat)::ms => playhead;
        playhead => previous_playhead;
    }

    fun void pos(int measures, float beats) // CHANGE THIS TO USE ACTUAL MEASURES AND BEATS
    {
        flushNotes();
        // <<<"moving playhead to position (measure, beats):", measures, beats>>>;
        60000 / score.bpm => float ms_per_beat;
        (measures * (ms_per_beat * score.time_sig_numerator * (4 / score.time_sig_denominator)) + beats * ms_per_beat)::ms => playhead;
        playhead => previous_playhead;
    }

    // Private functions
    fun void tickDriver()
    {
        while (playing)
        {
            if (playhead > end_of_score)
            {
                if (loop) pos(0);
                else stop();
            }
            if (playhead < start_of_score)
            {
                if (loop) pos(end_of_score);
                else stop();
            }
            
            for(int i; i < parts.size(); i++)
            {
                getNotesAtPlayhead(i);
            }

            // <<< playhead/ms >>>;
            tick * rate => tatum;
            playhead => previous_playhead;
            tatum +=> playhead;
            tick => now;
        }
        tick_driver_end.signal();
    }

    fun void stop_listener()
    {
        tick_driver_end => now;
        pos(0);
    }

    fun void flushNotes()
    {
        // <<<"flushing notes">>>;
        for(int part; part < parts.size(); part++)
        {
            for(int voice; voice < instruments[part]._n_voices; voice++)
            {
                // <<<"releasing voice", voice, "for part", part>>>;
                instruments[part].release_voice(voice);
            }
        }
    }

    fun int playheadPassedTime(float timestamp)
    {
        return (Math.min(previous_playhead/ms, playhead/ms) <= timestamp && timestamp < Math.max(previous_playhead/ms, playhead/ms));
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
                theMeasure.onset * ms_per_beat => float theMeasure_onset_ms;
                theMeasure.notes[j] @=> ezNote theNote;
                theMeasure_onset_ms + theNote.onset * ms_per_beat => float theNote_onset_ms;
                
                if(playheadPassedTime(theNote_onset_ms))
                {
                    currentNotes << theNote;
                }
            }
        }
        if(currentNotes.size() > 0)
        {
            for(int i; i < currentNotes.size(); i++)
            {
                spork ~ playNote(partIndex, currentNotes[i]);
            }
        }
    }

    fun void playNote(int partIndex, ezNote theNote)
    {
        instruments[partIndex].allocate_voice(theNote) => int voice_index;
        instruments[partIndex].noteOn(theNote, voice_index);

        if(log_playback)
        {
            chout <= "playing note " <= theNote.pitch <= " on voice " <= voice_index <= " for part " <= partIndex <= " at time " <= playhead/ms <= "ms," <= " at beat onset " <= theNote.onset <= " for " <= theNote.beats <= " beats, with velocity " <= theNote.velocity <= IO.newline();
        }

        playhead/ms => float onset_ms;
        60000 / score.bpm => float ms_per_beat;
        theNote.beats * ms_per_beat => float duration_ms;
        Math.sgn(rate) => float direction;

        while((playhead/ms - onset_ms)*direction < duration_ms) 
        {
            tick => now;
        }

        instruments[partIndex].release_voice(voice_index);
    }
}

