@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck"}

public class ezScore
{
    
    // Private variables
    120 => float _bpm;
    4 => int _time_sig_numerator;
    4 => int _time_sig_denominator;

    // Public variables
    ezPart parts[0];
    
    // Constructors
    // --------------------------------------------------------------------------
    fun ezScore(string input)
    {
        if(input.length() > 4 && input.substring(input.length() - 4,4) == ".mid")
        {
            importMIDI(input);
        }
        else
        {
            setPart(input);
        }
    }

    fun ezScore(string filename, float newBpm)
    {
        newBpm => _bpm;

        if(filename.length() > 4 && filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
    }

    // Public functions

    // Member variable get/set functions
    fun void bpm(float newBpm)
    {
        newBpm => _bpm;
    }

    fun float bpm()
    {
        return _bpm;
    }

    fun void setTimeSig(int numerator, int denominator)
    {
        numerator => _time_sig_numerator;
        denominator => _time_sig_denominator;
    }

    fun int numParts()
    {
        return parts.size();
    }

    fun void addPart(ezPart part)
    {
        parts << part;
    }

    // returns the end of the score in beats (the last note's release point)
    fun float scoreEnd()
    {
        float last_note_offset;
        for (int i; i < numParts(); i++)
        {
            parts[i] @=> ezPart part;
            for (int j; j < part.measures.size(); j++)
            {
                part.measures[j] @=> ezMeasure measure;
                for (int k; k < measure.notes.size(); k++)
                {
                    
                    measure.notes[k] @=> ezNote note;
                    measure.onset() + note.onset() + note.beats() => float offset;
                    if (offset > last_note_offset) offset => last_note_offset;
                }
            }
        }
        return last_note_offset;
    }

    fun dur scoreDuration()
    {
        return (scoreEnd() * 60000 / _bpm)::ms;
    }

    fun int maxPolyphony(int part)
    {
        return parts[part]._maxPolyphony;
    }
    
    // SMucKish input
    // --------------------------------------------------------------------------
    fun void setPart(string input)
    {
        ezPart part(input);
        addPart(part);
    }

    fun void setPart(string input, int fill_mode)
    {
        ezPart part(input, fill_mode);
        addPart(part);
    }

    fun void setPitches(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input);
            addPart(part);
        }
        else
        {
            parts[-1].setPitches(input);
        }
    }

    fun void setPitches(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input);
            addPart(part);
        }
    }

    fun void setPitches(int input[][])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input);
            addPart(part);
        }
    }

    fun void setPitches(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input, fill_mode);
            addPart(part);
        }
        else
        {
            parts[-1].setPitches(input, fill_mode);
        }
    }

    fun void setRhythms(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input);
            addPart(part);
        }
        else
        {
            parts[-1].setRhythms(input);
        }
    }

    fun void setRhythms(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input);
            addPart(part);
        }
    }

    fun void setRhythms(float input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input);
            addPart(part);
        }
    }
    
    fun void setRhythms(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input, fill_mode);
            addPart(part);
        }
        else
        {
            parts[-1].setRhythms(input, fill_mode);
        }
    }

    fun void setVelocities(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input);
            addPart(part);
        }
        else
        {
            parts[-1].setVelocities(input);
        }
    }

    fun void setVelocities(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input);
            addPart(part);
        }
    }

    fun void setVelocities(int input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input);
            addPart(part);
        }
    }

    fun void setVelocities(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input, fill_mode);
            addPart(part);
        }
        else
        {
            parts[-1].setVelocities(input, fill_mode);
        }
    }

    fun void importMIDI(string filename) {
        MidiFileIn min;
        MidiMsg msg;
        
        if( !min.open(filename) ) me.exit();
        // min.beatsPerMinute() => bpm; // DOESN'T WORK TO RETRIEVE BPM FROM MIDI FILE

        for (0 => int track; track < min.numTracks(); track++) {
            ezPart part;
            0 => int currPolyCount;

            float note_on_time[128];    // stores the note onset times (ms) for Note-On events, indexed by pitch
            int note_index[128];       // stores the latest index a note was added to
            
            0 => float accumulated_time_ms;
            60000 / _bpm => float ms_per_beat;
            
            ezMeasure measure;
            part.measures << measure;
            
            while (min.read(msg, track)) {
                // update the accumulated time for the measure to present moment
                accumulated_time_ms + msg.when/ms => accumulated_time_ms;
                part.measures[-1] @=> ezMeasure current_measure;

                // Note On
                if ((msg.data1 & 0xF0) == 0x90 && msg.data2 > 0 && msg.data3 > 0) {
                    // <<< "NOTE ON!!", msg.data2 >>>;
                    msg.data2 => int pitch;
                    msg.data3 => int velocity;

                    // 1. Update the note onset time for received pitch
                    accumulated_time_ms => note_on_time[pitch];

                    // 2. Add temporary note (undetermined duration) to the measure
                    accumulated_time_ms / ms_per_beat => float onset_time_beats;
                    ezNote tempNote(onset_time_beats, 0, pitch, velocity);           // 0 as temporary duration, will update when the note ends
                    current_measure.notes << tempNote;
                    
                    // 3. Store the index in the measure for that pitch, so we can find it's associated note when we need to update duration
                    current_measure.notes.size() - 1 => note_index[pitch];

                    // increase polyphony count by 1
                    1 +=> currPolyCount;

                    // update max polyphony
                    if (part._maxPolyphony < currPolyCount)
                    {
                        currPolyCount => part._maxPolyphony;
                    }
                }

                // Note Off
                if ((msg.data1 & 0xF0) == 0x80 && msg.data2 > 0 && msg.data3 > 0) {
                    // <<< "NOTE OFF", msg.data2 >>>;
                    msg.data2 => int pitch;
                    msg.data3 => int velocity;

                    // 1. Find note duration for given pitch
                    (accumulated_time_ms - note_on_time[pitch]) / ms_per_beat => float note_duration_beats;

                    // 2. Update the duration of the relevant note
                    note_duration_beats => current_measure.notes[note_index[pitch]].beats;

                    // decrease polyphony count by 1;
                    1 -=> currPolyCount;
                }
            }

            if(part._maxPolyphony > 0)
            {
                parts << part;
            }
        }
    }
}