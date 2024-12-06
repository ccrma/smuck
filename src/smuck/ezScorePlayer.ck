@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezNoteEvent.ck", "ezPreviewInst.ck", "ezInstrument.ck"}

public class ScorePlayer
{
    ezScore score;
    ezPart parts[];
    NoteEvent nextNotes[];

    ezInstrument graphs[];

    // set up sound for preview
    // defaultVoice previewGraphs[];
    // Gain previewGain;
    // previewGain.gain(0.0);
    // previewGain => dac;
    

    // "subvoice" - an individual ugen in the overall voice array a subvoice
    int subvoice_to_midi[][];       // -1 if subvoice is not in use (free), otherwise has the current midi pitch number it is being used for

    1 => float rate;
    1::ms => dur tick;
    dur tatum;
    dur playhead;


    fun ScorePlayer(ezScore s)
    {
        s @=> score;
        s.parts @=> parts;
        <<<parts.size(), "parts processed">>>;
        // create note events for broadcasting (might not need this)
        new NoteEvent[parts.size()] @=> nextNotes;

        // create chugraphs
        new ezInstrument[parts.size()] @=> graphs;
        // create default voices for preview playback
        // new defaultVoice[parts.size()] @=> previewGraphs;

        for(int i; i < parts.size(); i++)
        {
            // check contents of imported parts, assign polyphony to chugraph voices
            cherr <= "part " <= i <= " has " <= parts[i].measures[0].notes.size() <= " notes, and max polyphony of " <= parts[i].maxPolyphony <= IO.newline();
            parts[i].maxPolyphony => graphs[i].n_voices;

            // set up preview voice polyphony and connect to gain
            // parts[i].maxPolyphony => previewGraphs[i].n_voices;
            // previewGraphs[i] => previewGain;
        }
        
        // keep track of which subvoices are currently in use
        new int[parts.size()][0] @=> subvoice_to_midi;

        spork ~ tickDriver();
    }

    // fun void start()
    // {
    //     spork~tickDriver();
    // }

    fun void tickDriver()
    {
        // 5::second => now;   // DELETE THIS
        while(true)
        {
            tick * rate => tatum;
            tatum +=> playhead;
            // <<< playhead/ms >>>;
            for(int i; i < parts.size(); i++)
            {
                getNotesAtPlayhead(i);
            }
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
            for(int subvoice; subvoice < graphs[part].n_voices; subvoice++)
            {
                graphs[part].noteOff(subvoice);
                release_subvoice(part, subvoice);
            }
        }
    }

    fun void setVoice(int part, ezInstrument voice)
    {
        parts[part].maxPolyphony => voice.n_voices;
        voice @=> graphs[part];
        
        // keep track of which subvoices are currently in use
        new int[voice.n_voices] @=> subvoice_to_midi[part];
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
                theMeasure.notes[j] @=> ezNote theNote;
                theNote.onset * ms_per_beat => float theNote_onset;
                

                if(Math.fabs(theNote_onset - playhead/ms) < Math.fabs(tatum/ms))        // take abs of tatum too!!!
                {
                    //<<< "abs(onset-playhead) =",  Math.fabs(theNote_onset - playhead/ms)>>>;
                    //<<< "added note to currentNotes:", theNote_onset >>>;
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
                spork ~playNoteWrapper(partIndex, currentNotes[i]);
            }
            //nextNotes[partIndex].broadcast();
        }
    }

    fun void playNoteWrapper(int partIndex, ezNote theNote)
    {
        allocate_subvoice(partIndex, theNote) => int which_subvoice;
        graphs[partIndex].noteOn(which_subvoice, theNote);

        playhead/ms => float onset_ms;
        60000 / score.bpm => float ms_per_beat;
        theNote.beats * ms_per_beat => float duration_ms;
        Math.sgn(rate) => float direction;

        while((playhead/ms - onset_ms)*direction < duration_ms) 
        {
            tick => now;
        }

        graphs[partIndex].noteOff(which_subvoice);
        release_subvoice(partIndex, which_subvoice);
    }

    // Returns index of currently in-use subvoice for note. If the note doesn't have a subvoice, allocates a new one and returns the index. 
    fun int allocate_subvoice(int partIndex, ezNote theNote)
    {
        // If the note already has a subvoice in use, return that subvoice (only known case: reversal of playback)
        graphs[partIndex].n_voices => int num_subvoices_for_part;
        for (int subvoice_index; subvoice_index < num_subvoices_for_part; subvoice_index++)
        {
            subvoice_to_midi[partIndex][subvoice_index] => int pitch;
            if (pitch == theNote.pitch) return subvoice_index;
        }

        // If the note doesn't have a subvoice, allocate one!
        get_free_subvoice(partIndex) => int free_subvoice_index;                // find a free subvoice for the note
        if (free_subvoice_index == -1)      // if there are no free subvoices, free one at random
        {
            Math.random2(0, graphs[partIndex].n_voices - 1) => free_subvoice_index;
            release_subvoice(partIndex, free_subvoice_index);
        }
        theNote.pitch => subvoice_to_midi[partIndex][free_subvoice_index];                // marking the new subvoice as in use by the note
        return free_subvoice_index;
    }

    // Helper for grab_subvoice(). Returns the lowest index of a free subvoice for a given part (or random index if there are no free subvoices).
    fun int get_free_subvoice(int partIndex)
    {
        graphs[partIndex].n_voices => int n_voices;
        int free_subvoice_index;
        for (int i; i < n_voices; i++) {
            if (subvoice_to_midi[partIndex][i] == -1)       // if subvoice i is free
            {
                return i;
            }
        }
        // if none are free return -1
        return -1;
    }

    // Releases the subvoice that was in use for a specific note
    fun void release_subvoice(int partIndex, int subvoice_index)
    {
        // <<< "part index:", partIndex, "| n_voices:", graphs[partIndex].n_voices, "| num subvoices", subvoice_to_midi[partIndex].size(), "| subvoice index:", subvoice_index >>>;
        -1 => subvoice_to_midi[partIndex][subvoice_index];
    }

    fun void preview()
    {
        // new defaultVoice[parts.size()] @=> graphs;
        for(int i; i < parts.size(); i++)
        {
            defaultVoice tempVoice;
            setVoice(i, tempVoice);
            parts[i].maxPolyphony => graphs[i].n_voices;
            // graphs[i] => previewGain;
        }
        pos(0.0);
        // previewGain.gain(1.0);
        // spork ~ tickDriver();
    }

}

