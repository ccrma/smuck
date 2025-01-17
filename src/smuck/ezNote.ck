public class ezNote
{
    // Onset in beats, relative to start of measure (float)
    0.0 => float onset;
    // Duration in beats (float) 
    1.0 => float beats;
    // Pitch as a MIDI note number (int)
    60 => int pitch;
    // Velocity 0-127 (int)
    100 => int velocity;

    int CC[128];

    fun ezNote(float o, float b, int p, int v)
    {
        o => onset;
        b => beats;
        p => pitch;
        v => velocity;
    }

    fun void set_onset(float o)
    {
        o => onset;
    }

    fun void set_beats(float b) 
    {
        b => beats;
    }

    fun void set_pitch(int p)
    {
        p => pitch;
    }

    fun void set_velocity(int v)
    {
        v => velocity;
    }
}