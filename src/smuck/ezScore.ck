@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck"}

public class ezScore
{
    ezPart parts[0];

    120 => float bpm;
    4 => int time_sig_numerator;
    4 => int time_sig_denominator;
    
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
            set_part(input);
        }
    }

    fun ezScore(string filename, float newBpm)
    {
        newBpm => bpm;

        if(filename.length() > 4 && filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
    }

    // API 
    // --------------------------------------------------------------------------
    fun void setTempo(float newBpm)
    {
        newBpm => bpm;
    }

    fun void setTimeSig(int numerator, int denominator)
    {
        numerator => time_sig_numerator;
        denominator => time_sig_denominator;
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
    fun float getScoreEnd()
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
                    measure.onset + note.onset + note.beats => float offset;
                    if (offset > last_note_offset) offset => last_note_offset;
                }
            }
        }
        return last_note_offset;
    }

    fun dur getScoreDuration()
    {
        return (getScoreEnd() * 60000 / bpm)::ms;
    }

    fun int maxPolyphony(int part)
    {
        return parts[part].maxPolyphony;
    }
    
    // SMucKish input
    // --------------------------------------------------------------------------
    fun void set_part(string input)
    {
        ezPart part(input);
        add_part(part);
    }

    fun void set_part(string input, int fill_mode)
    {
        ezPart part(input, fill_mode);
        add_part(part);
    }

    fun void set_pitches(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_pitches(input);
            add_part(part);
        }
        else
        {
            parts[-1].set_pitches(input);
        }
    }

    fun void set_pitches(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_pitches(input);
            add_part(part);
        }
    }

    fun void set_pitches(int input[][])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_pitches(input);
            add_part(part);
        }
    }

    fun void set_pitches(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_pitches(input, fill_mode);
            add_part(part);
        }
        else
        {
            parts[-1].set_pitches(input, fill_mode);
        }
    }

    fun void set_rhythms(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_rhythms(input);
            add_part(part);
        }
        else
        {
            parts[-1].set_rhythms(input);
        }
    }

    fun void set_rhythms(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_rhythms(input);
            add_part(part);
        }
    }

    fun void set_rhythms(float input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_rhythms(input);
            add_part(part);
        }
    }
    
    fun void set_rhythms(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_rhythms(input, fill_mode);
            add_part(part);
        }
        else
        {
            parts[-1].set_rhythms(input, fill_mode);
        }
    }

    fun void set_velocities(string input)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_velocities(input);
            add_part(part);
        }
        else
        {
            parts[-1].set_velocities(input);
        }
    }

    fun void set_velocities(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_velocities(input);
            add_part(part);
        }
    }

    fun void set_velocities(int input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_velocities(input);
            add_part(part);
        }
    }

    fun void set_velocities(string input, int fill_mode)
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.set_velocities(input, fill_mode);
            add_part(part);
        }
        else
        {
            parts[-1].set_velocities(input, fill_mode);
        }
    }

    // Import MIDI file
    // --------------------------------------------------------------------------
    fun void importMIDI(string filename) {
        MidiFileIn min;
        MidiMsg msg;
        
        if( !min.open(filename) ) me.exit();
        // min.beatsPerMinute() => bpm;

        for (0 => int track; track < min.numTracks(); track++) {
            ezPart part;
            0 => int currPolyCount;

            float note_on_time[128];    // stores the note onset times (ms) for Note-On events, indexed by pitch
            int note_index[128];       // stores the latest index a note was added to
            
            0 => float accumulated_time_ms;
            60000 / bpm => float ms_per_beat;
            
            ezMeasure measure1;
            part.measures << measure1;
            
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
                    if (part.maxPolyphony < currPolyCount)
                    {
                        currPolyCount => part.maxPolyphony;
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

            if(part.maxPolyphony > 0)
            {
                parts << part;
            }
        }
    }
}