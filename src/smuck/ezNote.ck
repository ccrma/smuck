@import "smScore.ck"

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
    float _data[0];

    // Rest flag (boolean)
    @doc "(hidden)"
    0 => int _isRest;

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

    @doc "Constructor for ezNote using a SMucKish input string"
    fun ezNote(string sm_input)
    {
        smScore score;
        score.parse_interleaved(sm_input);
        if(score.pitches[0].size() > 0)
        {
            score.pitches[0][0] => _pitch;
        }
        else
        {
            true => _isRest;
        }

        if(score.rhythms.size() > 0)
        {
            score.rhythms[0] => _beats;
        }
        else
        {
            <<<"WTF? How did you enter a note with no rhythm?">>>;
        }
        if(score.velocities.size() > 0)
        {
            score.velocities[0] => _velocity;
        }
        else
        {
            <<<"WTF? How did you enter a note with no velocity?">>>;
        }
    }

    @doc "Return a copy of the ezNote"
    fun ezNote copy()
    {
        ezNote newNote;

        _onset => newNote._onset;
        _beats => newNote._beats;
        _pitch => newNote._pitch;
        _velocity => newNote._velocity;
        _text => newNote._text;
        _data @=> newNote._data;
        _isRest => newNote._isRest;

        return newNote;
    }

    @doc "get the onset of the note in beats, relative to the start of the measure"
    fun float onset()
    {
        return _onset;
    }

    @doc "set the onset of the note in beats, relative to the start of the measure"
    fun float onset(float value)
    {
        value => _onset;
        return _onset;
    }

    @doc "get the duration of the note in beats"
    fun float beats()
    {
        return _beats;
    }

    @doc "set the duration of the note in beats"
    fun float beats(float value) 
    {
        value => _beats;
        return _beats;
    }

    @doc "get the pitch of the note as a MIDI note number"
    fun float pitch()
    {
        return _pitch;
    }

    @doc "set the pitch of the note as a MIDI note number"
    fun float pitch(float value)
    {
        value => _pitch;
        return _pitch;
    }

    @doc "get the velocity of the note"
    fun float velocity()
    {
        return _velocity;
    }

    @doc "set the velocity of the note"
    fun float velocity(float value)
    {
        value => _velocity;
        return _velocity;
    }

    @doc "get the text annotation associated with the note"
    fun string text()
    {
        return _text;
    }

    @doc "set the text annotation associated with the note"
    fun string text(string value)
    {
        value => _text;
        return _text;
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
    fun float[] data(float value[])
    {
        value @=> _data;
        return _data;
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
    fun float data(int index, float value)
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
        return _data[index];
    }

    @doc "return whether the note is a rest"
    fun int isRest()
    {
        return _isRest;
    }

    @doc "set whether the note is a rest"
    fun int isRest(int value)
    {
        value => _isRest;
        return _isRest;
    }

    @doc "print the note parameters"
    fun void print()
    {
        chout <= "--------------------------------" <= IO.newline();
        chout <= "   Onset: " <= _onset <= IO.newline();
        chout <= "   Beats: " <= _beats <= IO.newline();
        chout <= "   Pitch: " <= _pitch <= " (" <= smUtils.mid2str(_pitch) <= ")" <= IO.newline();
        chout <= "Velocity: " <= _velocity <= IO.newline();
        chout <= "    Rest: ";
        if(_isRest)
        {
            chout <= "true" <= IO.newline();
        }
        else
        {
            chout <= "false" <= IO.newline();
        }
        if(_text != "")
        {
            chout <= "    Text: " <= _text <= IO.newline();
        }
        if(_data.size() > 0)
        {
            chout <= "    Data: ";

            for(int i; i < _data.size(); i++)
            {
                chout <= _data[i] <= " ";
            }
            chout <= IO.newline();
        }
        chout <= "--------------------------------" <= IO.newline();
    }

    @doc "(hidden)"
    fun void printLine()
    {
        chout <= "Onset: " <= _onset <= ", ";
        chout <= "Beats: " <= _beats <= ", ";
        chout <= "Pitch: " <= _pitch <= " (" <= smUtils.mid2str(_pitch) <= ")" <= ", ";
        chout <= "Velocity: " <= _velocity <= ", ";
        chout <= "Rest: " <= _isRest <= "";
        if(_text != "")
        {
            chout <= ", Text: " <= _text;
        }
        if(_data.size() > 0)
        {
            chout <= ", Data: ";
            for(int i; i < _data.size(); i++)
            {
                chout <= _data[i] <= " ";
            }
        }
        chout <= IO.newline();
    }
    
}