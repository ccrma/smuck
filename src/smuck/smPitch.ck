@import "smUtils.ck"

public class smPitch
{
    //--------------------------------------------------------
    // Helper functions
    //--------------------------------------------------------

    fun static int[] getKeyVector(string key_token)
    {
        int keyVector[7];

        if(key_token.length() == 3)
        {
            key_token.substring(2,1) => string type;
            Std.atoi(key_token.substring(1,1)) => int n;

            if(n > 7)
            {
                <<<"ERROR: Not a valid key signature--must have at most 7 sharps/flats">>>;
                return keyVector;
            }
            if(type != "s" && type != "f" && type != "b" && type != "#")
            {
                <<<"ERROR: Not a valid key signature--signature type must be either 'f' / 'b' (flats) or 's' / '#' (sharps)">>>;
                return keyVector;
            }
            if(type == "s" || type == "#")
            {
                for(int i; i < n; i++)
                {
                    1 => keyVector[i];
                }
            }
            if(type == "f" || type == "b")
            {
                for(6 => int i; i > (6-n); i--)
                {
                    -1 => keyVector[i];
                }
            }
        }
        else
        {
            <<<"ERROR: Not a valid key signature. Token must be 3 characters long, e.g. 'k3f' or 'k1#'">>>;
        }

        return keyVector;
    }

    fun static int get_step(string char)
    {
        // Pitch map
        //--------------------------------------------------------
        // Create pitch map from pitch name (str) to MIDI note number (int)
        // note: 'r' = rest, assigned value of -999

        ["c", "d", "e", "f", "g", "a", "b", "r"] @=> string base_pitches[];
        [12, 14, 16, 17, 19, 21, 23, -999] @=> int base_notes[];
        int pitch_map[7];

        for (int i; i < base_pitches.size(); i++)
        {
            base_notes[i] => pitch_map[base_pitches[i]];
        }

        if(char.length() != 1)
        {
            <<<"ERROR: Invalid input. Must pass a single character string representing the pitch step">>>;
            return -1;
        }
        if("abcdefgr".find(char.lower()) == -1)
        {
            <<<"ERROR: not a valid pitch token. First character must be single character representing the pitch step ('a', 'b', 'c', etc.) or 'r' for rest" >>>;
            return -1;
        }

        return pitch_map[char];

    }

    fun static int get_alter(string token, int keyVector[])
    {
        token => string copy;
        
        // build associative array: key = pitch (string), value = alter (-1, 0, or 1)
        ["f", "c", "g", "d", "a", "e", "b"] @=> string circleFifths[];
        int keySig[0];
        for (int i; i < 7; i++)
        {
            keyVector[i] => keySig[circleFifths[i]];
        }

        if(copy.length() == 0)
        {
            <<<"ERROR: Empty input token">>>;
            return 0;
        }
        
        if(copy.length() == 1)
        {
            if(!keySig.isInMap(copy.substring(0,1)))
            {
                if(copy.substring(0,1) != "r")
                {
                    <<<"ERROR: Cannot get accidental. First character must represent a valid pitch step e.g. 'a', 'b', 'c'">>>;
                }
                return 0;
            }
            else
            {
                return keySig[copy.substring(0,1)];
            }
        }
        else
        {
            copy.substring(1) => string suffix;
            if(suffix.find("s") != -1 || suffix.find("#") != -1)
            {
                smUtils.count_substring(suffix, "s") => int num_s;
                smUtils.count_substring(suffix, "#") => int num_sharp;

                return num_s + num_sharp;
            }
            if(suffix.find("f") != -1 || suffix.find("b") != -1)
            {
                smUtils.count_substring(suffix, "f") => int num_f;
                smUtils.count_substring(suffix, "b") => int num_flat;

                return -1 * (num_f + num_flat);
            }
            if(suffix.find("n") != -1)
            {
                return 0;
            }
            return keySig[copy.substring(0,1)];
        }

    }

    fun static int get_octave(string token, int oct_cxt, int pitch, int last)
    {
        token => string copy;
        oct_cxt => int octave;
        
        if(copy.length() > 1)
        {
            copy.substring(1) => string suffix;

            // If explicit octave number present, use that
            if(smUtils.findInt(suffix) != -1)
            {
                return smUtils.find_int_from_index(copy, smUtils.findInt(copy));
            }

            // Use proximity from last note to determine octave
            if(pitch - last > 6)
            {
                octave--;
            }
            if(pitch - last <= -6 && last != 999)
            {
                octave++;
            }

            // If direction flags 'd'/'u' present, use those
            for(int i; i < smUtils.count_substring(suffix, "d"); i++)
            {
                octave--;
            }
            for(int i; i < smUtils.count_substring(suffix, "u"); i++)
            {
                octave++;
            }
        }
        else
        {
            if(pitch - last > 6)
            {
                octave--;
            }
            if(pitch - last <= -6 && last != 999)
            {
                octave++;
            }
        }
        return octave;
    }
    
    fun static int[][] parse_tokens(string tokens[])
    {
        int output[0][0];

        // Contextual variables
        // ----------------------------------------
        // key signature (can be set multiple times). Defaults to no accidentals.
        int keyVector[7];
        // octave can be set explicitly, or inferred by proximity to last note. Defaults to octave 4.
        4 => int oct_cxt;
        // last note parsed. Initialized to 999 for proximity calculation
        999 => int last_pitch;

        for(auto token : tokens)
        {
            // Parse key signature
            if(token.find("k") != -1)
            {
                getKeyVector(token) @=> keyVector;
                continue;
            }
            
            // Each token is processed as a chord even if it only has one note
            int chord[0];
            smUtils.split(token, ":") @=> string chord_notes[];
            for(auto note : chord_notes)
            {
                get_step(note.substring(0,1)) => int step;
                get_alter(note, keyVector) => int alter;
                get_octave(note, oct_cxt, step + alter, last_pitch) => int octave;

                // If an actual pitch and not a rest
                if(step >= 0)
                {
                    // set context variables
                    step + alter => last_pitch;
                    octave => oct_cxt;

                    // calculate current pitch and add to chord
                    Math.max(0, step + alter + 12 * (octave)) => int current_note;
                    chord << current_note;
                }
                // Otherwise, add a rest
                else
                {
                    chord << -999;
                }
            }
            output << chord;
        }
        return output;
    }

    // Parse a string of pitches into a 2D array of integers
    fun static int[][] parse_pitches(string input)
    {
        int output[0][0];

        // Contextual variables
        // ----------------------------------------
        // key signature (can be set multiple times). Defaults to no accidentals.
        int keyVector[7];
        // octave can be set explicitly, or inferred by proximity to last note. Defaults to octave 4.
        4 => int oct_cxt;
        // last note parsed. Initialized to 999 for proximity calculation
        999 => int last_pitch;

        // Handle repeated sequences and tokens
        smUtils.expand_repeats(input) => string expanded;
        // Split into tokens
        smUtils.split(expanded) @=> string tokens[];

        for(auto token : tokens)
        {
            // Parse key signature
            if(token.find("k") != -1)
            {
                getKeyVector(token) @=> keyVector;
                continue;
            }
            
            // Each token is processed as a chord even if it only has one note
            int chord[0];
            smUtils.split(token, ":") @=> string chord_notes[];
            for(auto note : chord_notes)
            {
                get_step(note.substring(0,1)) => int step;
                get_alter(note, keyVector) => int alter;
                get_octave(note, oct_cxt, step + alter, last_pitch) => int octave;

                // If an actual pitch and not a rest
                if(step >= 0)
                {
                    // set context variables
                    step + alter => last_pitch;
                    octave => oct_cxt;

                    // calculate current pitch and add to chord
                    Math.max(0, step + alter + 12 * (octave)) => int current_note;
                    chord << current_note;
                }
                // Otherwise, add a rest
                else
                {
                    chord << -999;
                }
            }
            output << chord;
        }

        return output;

    }

}