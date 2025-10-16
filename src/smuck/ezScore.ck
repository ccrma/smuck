@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck"}

@doc "SMucK score object. An ezScore object contains one or more ezParts. Score contents can be set using the SMucKish input syntax, or by importing a MIDI file. ezScore objects can be passed to an ezScorePlayer object for playback."
public class ezScore
{
    @doc "(hidden)"
    120 => float _bpm;
    @doc "(hidden)"
    ezPart _parts[0];
    
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
            add(input);
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
            add(input);
        }
    }

    @doc "Create an ezScore from an array of ezPart objects"
    fun ezScore(ezPart new_parts[])
    {
        new_parts @=> _parts;
    }

    // Public functions

    @doc "Get the parts for the score as an ezPart array"
    fun ezPart[] parts()
    {
        return _parts;
    }

    @doc "Set the parts for the score, using an ezPart array"
    fun ezPart[] parts(ezPart parts[])
    {
        parts @=> _parts;
        return _parts;
    }

    @doc "Set the tempo in BPM (beats per minute) for the score"
    fun float bpm(float value)
    {
        value => _bpm;
        return _bpm;
    }

    @doc "Get the tempo in BPM (beats per minute) for the score"
    fun float bpm()
    {
        return _bpm;
    }

    @doc "Add an ezPart to the score"
    fun void add(ezPart part)
    {
        _parts << part;
    }

    @doc "Add an ezPart to the score, using a SMucKish input string"
    fun void add(string input)
    {
        ezPart part(input);
        _parts << part;
    }

    @doc "Add multiple ezParts to the score, using an array of ezParts"
    fun void add(ezPart new_parts[])
    {
        for(int i; i < new_parts.size(); i++)
        {
            _parts << new_parts[i];
        }
    }

    @doc "Add multiple ezParts to the score, using an array of SMucKish strings"
    fun void add(string inputs[])
    {
        for(int i; i < inputs.size(); i++)
        {
            ezPart part(inputs[i]);
            _parts << part;
        }
    }

    @doc "Get the end of the score in beats (the last note's release point)"
    fun float beats()
    {
        float score_end;
        for (int i; i < _parts.size(); i++)
        {
            float part_length;
            _parts[i] @=> ezPart part;
            for (int j; j < part.measures().size(); j++)
            {
                part.measures()[j] @=> ezMeasure measure;
                measure.beats() +=> part_length;
            }
            if (part_length > score_end) part_length => score_end;
        }
        return score_end;
    }

    @doc "Get the duration of the score in milliseconds"
    fun dur duration()
    {
        return (beats() * 60000 / _bpm)::ms;
    }

    @doc "Get the maximum polyphony for a given part"
    fun int maxPolyphony(int part)
    {
        return _parts[part]._maxPolyphony;
    }

    @doc "Read a MIDI file into the ezScore object"
    fun void read(string filename)
    {
        if(filename.length() > 4 && filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
        else
        {
            chout <= "Cannot read file " <= filename <= " as it is not a MIDI file" <= IO.newline();
        }
    }

    @doc "(hidden)"
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
            part.measures() << measure;
            
            while (min.read(msg, track)) {
                // update the accumulated time for the measure to present moment
                // <<< "TIME", msg.when/ms >>>;
                accumulated_time_ms + msg.when/ms => accumulated_time_ms;
                part.measures()[-1] @=> ezMeasure current_measure;

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
                    current_measure.notes() << tempNote;
                    
                    // 3. Store the index in the measure for that pitch, so we can find it's associated note when we need to update duration
                    current_measure.notes().size() - 1 => note_index[pitch];

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
                    note_duration_beats => current_measure.notes()[note_index[pitch]].beats;

                    // decrease polyphony count by 1;
                    1 -=> currPolyCount;
                }
            }

            if(part._maxPolyphony > 0)
            {
                _parts << part;
            }
        }
    }
}