public class ezNote
{
    // Onset in beats, relative to start of measure (float)
    0.0 => float _onset;
    // Duration in beats (float) 
    1.0 => float _beats;
    // Pitch as a MIDI note number (int)
    60 => int _pitch;
    // Velocity 0-127 (int)
    100 => int _velocity;

    fun ezNote(float o, float b, int p, int v)
    {
        o => _onset;
        b => _beats;
        p => _pitch;
        v => _velocity;
    }

    fun float onset()
    {
        return _onset;
    }

    fun void onset(float o)
    {
        o => _onset;
    }

    fun float beats()
    {
        return _beats;
    }

    fun void beats(float b) 
    {
        b => _beats;
    }

    fun int pitch()
    {
        return _pitch;
    }

    fun void pitch(int p)
    {
        p => _pitch;
    }

    fun int velocity()
    {
        return _velocity;
    }

    fun void velocity(int v)
    {
        v => _velocity;
    }
}