@doc "Basic SMucK note object carrying information about the note's onset, duration, pitch, and velocity. To be used in score importing, generating, editing, and playback."
public class ezNote
{
    // Onset in beats, relative to start of measure (float)
    @doc "(hidden)"
    0.0 => float _onset;
    // Duration in beats (float) 
    @doc "(hidden)"
    1.0 => float _beats;
    // Pitch as a MIDI note number (float)
    @doc "(hidden)"
    60 => float _pitch;
    // Velocity 0.0-1.0 (float)
    @doc "(hidden)"
    1.0 => float _velocity;

    // Text annotation (string) - optional
    @doc "(hidden)"
    string _text;

    // User-defined data (float array) - optional
    @doc "(hidden)"
    float _data[];

    // Constructors
    // --------------------------------------------------------------------------
    @doc "Default constructor, creates a note with onset 0, duration 1, pitch 60, and velocity 1.0"
    fun ezNote()
    {

    }
    
    @doc "Constructor for ezNote specifying onset, beats, pitch, and velocity"
    fun ezNote(float onset, float beats, float pitch, float velocity)
    {
        onset => _onset;
        beats => _beats;
        pitch => _pitch;
        velocity => _velocity;
    }

    @doc "get the onset of the note in beats, relative to the start of the measure"
    fun float onset()
    {
        return _onset;
    }

    @doc "set the onset of the note in beats, relative to the start of the measure"
    fun void onset(float value)
    {
        value => _onset;
    }

    @doc "get the duration of the note in beats"
    fun float beats()
    {
        return _beats;
    }

    @doc "set the duration of the note in beats"
    fun void beats(float value) 
    {
        value => _beats;
    }

    @doc "get the pitch of the note as a MIDI note number"
    fun float pitch()
    {
        return _pitch;
    }

    @doc "set the pitch of the note as a MIDI note number"
    fun void pitch(float value)
    {
        value => _pitch;
    }

    @doc "get the velocity of the note"
    fun float velocity()
    {
        return _velocity;
    }

    @doc "set the velocity of the note"
    fun void velocity(float value)
    {
        value => _velocity;
    }

    @doc "get the text annotation associated with the note"
    fun string text()
    {
        return _text;
    }

    @doc "set the text annotation associated with the note"
    fun void text(string value)
    {
        value => _text;
    }
    
    @doc "get the user-defined data associated with the note"
    fun float[] data()
    {
        if(_data == null)
        {
            float newData[0];
            newData @=> _data;
        }
        return _data;
    }

    @doc "set the user-defined data associated with the note, using a float array"
    fun void data(float value[])
    {
        value @=> _data;
    }
    
    @doc "get the user-defined data associated with the note, using an index"
    fun float data(int index)
    {
        if(_data == null)
        {
            float newData[0];
            newData @=> _data;
        }
        
        if(index >= _data.size())
        {
            cherr <= "ezNote: data index out of bounds" <= IO.newline();
            return -999;
        }
        return _data[index];
    }

    @doc "set the user-defined data associated with the note, using an index"
    fun void data(int index, float value)
    {
        _data.size() => int size;
        
        // If index is beyond current size, resize array
        if(index >= size)
        {
            float newData[index + 1];
            // Copy existing data
            for(0 => int i; i < size; i++)
            {
                _data[i] => newData[i];
            }
            // Set new value
            value => newData[index];
            newData @=> _data;
        }
        else
        {
            // Index is within bounds, just set the value
            value => _data[index];
        }
    }
    
}