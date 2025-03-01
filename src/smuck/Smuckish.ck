@import {"smUtils.ck", "smPitch.ck", "smRhythm.ck", "smVelocity.ck", "smScore.ck", "smChord.ck", "smScale.ck"}

@doc "A collection of static functions for parsing and manipulating symbolic music notation into ChucK data structures. For more information on SMucKish, see https://chuck.stanford.edu/smuck/doc/cheatsheet.html"
public class Smuckish
{
    @doc "Parse a SMucKish string representing pitches into a 2D array of MIDI note numbers (floats). Indexed first by position in sequence, second by polyphonic voice. A monophonic sequence will always have a second dimension size of 1."
    fun static float[][] pitches(string input)
    {
        return smPitch.parse_pitches(input);
    }

    @doc "Parse a SMucKish string representing rhythms into an array of beat values (i.e. 1.0 = quarter note, 2.0 = half note, etc.). Indexed by position in sequence."
    fun static float[] rhythms(string input)
    {
        return smRhythm.parse_rhythms(input);
    }

    @doc "Parse a SMucKish string representing velocities into an array of float values (0.0-1.0). Indexed by position in sequence."
    fun static float[] velocities(string input)
    {
        return smVelocity.parse_velocities(input);
    }

    @doc "Parse a chord symbol (e.g. 'Gbmaj7#11') into an array of MIDI note numbers (ints). Assumes octave of 0. See https://chuck.stanford.edu/smuck/doc/chords.html for full list of valid chord symbols."
    fun static int[] chord(string input)
    {
        smChord chord(input);
        return chord.notes;
    }

    @doc "Parse a chord symbol (e.g. 'Gbmaj7#11') into an array of MIDI note numbers (ints). Uses the given octave. See https://chuck.stanford.edu/smuck/doc/chords.html for full list of valid chord symbols."
    fun static int[] chord(string input, int octave)
    {
        smChord chord(input, octave);
        return chord.notes;
    }

    @doc "Parse a scale name (e.g. 'major') into an array of MIDI note numbers (ints). Assumes root of C0. See https://chuck.stanford.edu/smuck/doc/scales.html for full list of valid scale types."
    fun static int[] scale(string name)
    {
        smScale scale(name);
        return scale.notes;
    }

    @doc "Parse a scale name (e.g. 'major') into an array of MIDI note numbers (ints). Uses the given root note. See https://chuck.stanford.edu/smuck/doc/scales.html for full list of valid scale types."
    fun static int[] scale(string name, int root)
    {
        smScale scale(name, root);
        return scale.notes;
    }

    @doc "Parse a scale name (e.g. 'major') into an array of MIDI note numbers (ints). Uses the given root note name (e.g. 'C4'). See https://chuck.stanford.edu/smuck/doc/scales.html for full list of valid scale types."
    fun static int[] scale(string name, string rootName)
    {
        smScale scale(name, smUtils.str2mid(rootName));
        return scale.notes;
    }
}