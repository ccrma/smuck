public class ezNote
{
    // Onset in beats, relative to start of measure (float)
    float onset;
    // Duration in beats (float) 
    float beats;
    // Pitch as a MIDI note number (int)
    int pitch;
    // Velocity 0-127 (int)
    int velocity;

    fun ezNote(float o, float b, int p, int v)
    {
        o => onset;
        b => beats;
        p => pitch;
        v => velocity;
    }
}