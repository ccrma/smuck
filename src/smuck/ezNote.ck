@doc "Basic SMucK note object carrying information about the note's onset, duration, pitch, and velocity. To be used in score importing, generating, editing, and playback."
public class ezNote
{
    // Onset in beats, relative to start of measure (float)
    @doc "(hidden)"
    0.0 => float _onset;
    // Duration in beats (float) 
    @doc "(hidden)"
    1.0 => float _beats;
    // Pitch as a MIDI note number (int)
    @doc "(hidden)"
    60 => int _pitch;
    // Velocity 0-127 (int)
    @doc "(hidden)"
    100 => int _velocity;

    // Constructors
    // --------------------------------------------------------------------------
    @doc "Default constructor, creates a note with onset 0, duration 1, pitch 60, and velocity 100"
    fun ezNote()
    {

    }
    
    @doc "Constructor for ezNote specifying onset, beats, pitch, and velocity"
    fun ezNote(float onset, float beats, int pitch, int velocity)
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
    fun int pitch()
    {
        return _pitch;
    }

    @doc "set the pitch of the note as a MIDI note number"
    fun void pitch(int value)
    {
        value => _pitch;
    }

    @doc "get the velocity of the note, value between 0 and 127"
    fun int velocity()
    {
        return _velocity;
    }

    @doc "set the velocity of the note, value between 0 and 127"
    fun void velocity(int value)
    {
        value => _velocity;
    }
}