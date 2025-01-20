@import {"smUtils.ck", "smPitch.ck", "smRhythm.ck", "smVelocity.ck", "smScore.ck", "smChord.ck", "smScale.ck"}

public class smuckish
{
    fun static int[][] pitches(string input)
    {
        return smPitch.parse_pitches(input);
    }

    fun static float[] rhythms(string input)
    {
        return smRhythm.parse_rhythms(input);
    }

    fun static int[] velocities(string input)
    {
        return smVelocity.parse_velocities(input);
    }

    fun static int[] chord(string input)
    {
        smChord chord(input);
        return chord.notes;
    }

    fun static int[] chord(string input, int octave)
    {
        smChord chord(input, octave);
        return chord.notes;
    }

    fun static int[] scale(string name)
    {
        smScale scale(name);
        return scale.notes;
    }

    fun static int[] scale(string name, int root)
    {
        smScale scale(name, root);
        return scale.notes;
    }

    fun static int[] scale(string name, string rootName)
    {
        smScale scale(name, smUtils.str2mid(rootName));
        return scale.notes;
    }
}