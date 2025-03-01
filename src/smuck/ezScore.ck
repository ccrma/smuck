@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck"}

@doc "SMucK score object. An ezScore object contains one or more ezParts. Score contents can be set using the SMucKish input syntax, or by importing a MIDI file. ezScore objects can be passed to an ezScorePlayer object for playback."
public class ezScore
{
    // Private variables
    @doc "(hidden)"
    120 => float _bpm;
    @doc "(hidden)"
    4 => int _time_sig_numerator;
    @doc "(hidden)"
    4 => int _time_sig_denominator;

    // Public variables
    @doc "The ezPart objects in the score"
    ezPart parts[0];
    
    // Constructors
    // --------------------------------------------------------------------------
    @doc "Default constructor, creates an empty score"
    fun ezScore()
    {

    }

    @doc "Create an ezScore from a SMucKish input string or MIDI file. If the input argument is a MIDI filename (ending in .mid), the MIDI file is imported. Otherwise, the input string is interpreted as a SMucKish input string."
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

    @doc "Create an ezScore from a SMucKish input string or MIDI file, with a specified BPM"
    fun ezScore(string input, float bpm)
    {
        bpm => _bpm;

        if(input.length() > 4 && input.substring(input.length() - 4,4) == ".mid")
        {
            importMIDI(input);
        }
        else
        {
            setPart(input);
        }
    }

    // Public functions

    // Member variable get/set functions
    @doc "Set the tempo in BPM (beats per minute) for the score"
    fun void bpm(float value)
    {
        value => _bpm;
    }

    @doc "Get the tempo in BPM (beats per minute) for the score"
    fun float bpm()
    {
        return _bpm;
    }

    @doc "Set the time signature for the score"
    fun void setTimeSig(int numerator, int denominator)
    {
        numerator => _time_sig_numerator;
        denominator => _time_sig_denominator;
    }

    @doc "Get the number of parts in the score"
    fun int numParts()
    {
        return parts.size();
    }

    @doc "Add an ezPart to the score"
    fun void addPart(ezPart part)
    {
        parts << part;
    }

    @doc "Add an ezPart to the score, using a SMucKish input string"
    fun void addPart(string input)
    {
        ezPart part(input);
        parts << part;
    }

    @doc "Get the end of the score in beats (the last note's release point)"
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

    @doc "Get the duration of the score in milliseconds"
    fun dur scoreDuration()
    {
        return (scoreEnd() * 60000 / _bpm)::ms;
    }

    @doc "Get the maximum polyphony for a given part"
    fun int maxPolyphony(int part)
    {
        return parts[part]._maxPolyphony;
    }
    
    // SMucKish input
    // --------------------------------------------------------------------------
    @doc "(hidden)"
    fun void setPart(string input)
    {
        ezPart part(input);
        addPart(part);
    }

    @doc "(hidden)"
    fun void setPart(string input, int fill_mode)
    {
        ezPart part(input, fill_mode);
        addPart(part);
    }

    @doc "Set the pitches of the notes in the last part, using a SMucKish input string. If the score contains no parts, a new part is created."
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

    @doc "Set the pitches of the notes in the last part, using an array of SMucKish string tokens. If the score contains no parts, a new part is created."
    fun void setPitches(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input);
            addPart(part);
        }
    }

    @doc "Set the pitches of the notes in the last part, using a 2D array of MIDI note numbers (floats). If the score contains no parts, a new part is created."
    fun void setPitches(float input[][])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setPitches(input);
            addPart(part);
        }
    }

    @doc "(hidden)"
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

    @doc "Set the rhythms of the notes in the last part, using a SMucKish input string. If the score contains no parts, a new part is created."
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

    @doc "Set the rhythms of the notes in the last part, using an array of SMucKish string tokens. If the score contains no parts, a new part is created."
    fun void setRhythms(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input);
            addPart(part);
        }
    }

    @doc "Set the rhythms of the notes in the last part, using an array of floats. If the score contains no parts, a new part is created."
    fun void setRhythms(float input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setRhythms(input);
            addPart(part);
        }
    }
    
    @doc "(hidden)"
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

    @doc "Set the velocities of the notes in the last part, using a SMucKish input string. If the score contains no parts, a new part is created."
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

    @doc "Set the velocities of the notes in the last part, using an array of SMucKish string tokens. If the score contains no parts, a new part is created."
    fun void setVelocities(string input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input);
            addPart(part);
        }
    }

    @doc "Set the velocities of the notes in the last part, using an array of floats. If the score contains no parts, a new part is created."
    fun void setVelocities(float input[])
    {
        if(parts.size() == 0)
        {
            ezPart part;
            part.setVelocities(input);
            addPart(part);
        }
    }

    @doc "(hidden)"
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

    @doc "Read a MIDI file into the ezScore object"
    fun void importMIDI(string filename) {
        MidiFileIn min;
        MidiMsg msg;
        
        if( !min.open(filename) ) me.exit();
        // min.beatsPerMinute() => bpm; // DOESN'T WORK TO RETRIEVE BPM FROM MIDI FILE
        // <<<"EXTRACTED BPM: ", min.beatsPerMinute()>>>;
        // <<<"TICKS PER QUARTER: ", min.ticksPerQuarter()>>>;
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
                // <<< "TIME", msg.when/ms >>>;
                accumulated_time_ms + msg.when/ms => accumulated_time_ms;
                part.measures[-1] @=> ezMeasure current_measure;

                // Note On
                if ((msg.data1 & 0xF0) == 0x90 && msg.data2 > 0 && msg.data3 > 0) {
                    // <<< "NOTE ON!!", msg.data2, msg.data3 >>>;
                    msg.data2 => int pitch;
                    msg.data3 => int velocity;

                    // 1. Update the note onset time for received pitch
                    accumulated_time_ms => note_on_time[pitch];

                    // 2. Add temporary note (undetermined duration) to the measure
                    accumulated_time_ms / ms_per_beat => float onset_time_beats;
                    ezNote tempNote(onset_time_beats, 0, pitch, velocity/127.0);           // 0 as temporary duration, will update when the note ends
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
                if(((msg.data1 & 0xF0) == 0x80 && msg.data2 > 0) || ((msg.data1 & 0xF0) == 0x90 && msg.data3 == 0))
                {
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