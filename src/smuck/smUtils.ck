@doc "A variety of utility functions for working with SMucKish. Has some useful string handling functions applicable outside of SMucK."
public class smUtils
{
    //--------------------------------------------------------
    // String utility functions
    //--------------------------------------------------------

    // Split a string by given delimiter, return array of split elements
    @doc "Split a string into an array of strings, using a given delimiter."
    fun static string[] split(string input, string delimiter)
    {
        string output[0];
        input => string copy;

        while(copy.find(delimiter) != -1)
        {
            copy.find(delimiter) => int ix;
            copy.substring(0, ix) => string curr;
            if(curr.length() > 0){output << curr;}
            if(ix + delimiter.length() < copy.length())
            {
                copy.substring(ix + delimiter.length()) => copy;
            }
            else
            {
                return output;
            }
        }

        if(copy.length() > 0)
        {
            output << copy;
        }

        return output;
    }

    @doc "Split a string into an array of strings, using whitespace as the delimiter."
    fun static string[] split(string input)
    {
        string output[0];
        " " => string delim;

        input => string copy;

        while(copy.find(delim) != -1)
        {
            copy.find(delim) => int ix;
            copy.substring(0, ix) => string curr;
            if(curr.length() > 0){output << curr;}
            if(ix + delim.length() < copy.length())
            {
                copy.substring(ix + delim.length()) => copy;
            }
            else
            {
                return output;
            }
        }

        if(copy.length() > 0)
        {
            output << copy;
        }

        return output;
    }

    // Count the number of occurences of target substring in string
    @doc "Count the number of occurences of a target substring in a string."
    fun static int countSubstring(string input, string target)
    {
        input => string copy;
        0 => int index;
        0 => int count;

        while(copy.find(target) != -1)
        {
            count++;
            copy.find(target) => index;
            if(index + target.length() < copy.length())
            {
                copy.substring(index + target.length()) => copy;
            }
            else
            {
                return count;
            }
        }

        return count;
    }

    // Find leftmost occurence of an integer in a string, return index or -1 if none found
    @doc "Find the leftmost occurence of an integer in a string, return index or -1 if none found."
    fun static int findInt(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("0123456789".find(input.substring(i, 1)) != -1)
            {
                return i;
            }
        }

        return -1;
    }

    // Get longest valid integer in string starting at given index
    @doc "Get the longest valid integer in a string starting at a given index."
    fun static int findIntFromIndex(string input, int index)
    {
        input => string copy;
        1 => int len;
        0 => int ans;

        while(index + len <= copy.length())
        {
            Std.atoi(copy.substring(index, len)) => int candidate;
            if(candidate > ans)
            {
                candidate => ans;
            }
            len++;
        }

        return ans;
    }

    //--------------------------------------------------------
    // Smuckish syntax helper functions
    //--------------------------------------------------------

    // Handle repeated tokens
    //
    // Repeated tokens are denoted with 'x' followed by an integer
    // The token will be repeated that many times
    @doc "(hidden)"
    fun static string[] handle_repeat(string input)
    {
        string expanded[0];
        input.substring(0, input.find("x")) => string toClone;
        input.substring(input.find("x") + 1) => string toRepeat;
        toRepeat.toInt() => int nTimes;
        for(int i; i < nTimes; i++)
        {
            expanded << toClone;
        }
        return expanded;
    }

    // Handle a repeated sequence of tokens
    //
    // A sequence is demarcated by brackets '[', ']'
    // Number of repeats is specified with 'x' followed by an integer
    // Everyting within the brackets will be repeated that many times
    @doc "(hidden)"
    fun static string handle_sequence(string input)
    {
        input => string copy;

        // get the innermost sequence
        copy.rfind("[") => int left_bound;
        copy.find("]") => int right_bound;
        right_bound - left_bound - 1 => int seq_length;
        copy.substring(left_bound + 1, seq_length) => string sequence;

        findIntFromIndex(copy, right_bound + 2) => int n_repeats;

        // check that there is an 'x' immediately after ']'
        if(copy.substring(right_bound + 1, 1) != "x")
        {
            <<<"ERROR: sequences bound by '[]' must have a number of repeats specified">>>;
            return copy;
        }
        else
        {
            // Repeat the bracketed sequence n times
            " " => string output;
            for(int i; i < n_repeats; i++)
            {
                output.insert(output.length()-1, sequence);
                output.insert(output.length()-1, " ");
            }

            // Replace the bracketed pattern with the expanded, repeated sequence
            (right_bound + 2 + Std.itoa(n_repeats).length()) - left_bound => int pattern_length;
            copy.replace(left_bound, pattern_length, output.rtrim());

            return copy;
        }
    }

    // Find all bracketed sequences and expand with appropriate number of repeats
    // note: recursive!!
    @doc "(hidden)"
    fun static string expand_sequences(string input)
    {
        input => string copy;

        if(countSubstring(copy, "[") == 0 && countSubstring(copy, "]") == 0)
        {
            return copy;
        }
        else
        {
            // Check to see if left/right bracket counts match
            if(countSubstring(copy, "[") != countSubstring(copy, "]"))
            {
                <<< "ERROR: number of left brackets '[' and right brackets ']' must be same" >>>;
                return copy;
            }
            // Recursively expand the innermost sequence
            else
            {
                return expand_sequences(handle_sequence(copy));
            }
        }
    }

    // Expand all repeated tokens, return single string
    @doc "(hidden)"
    fun static string expand_tokens(string input)
    {
        input => string copy;

        if(countSubstring(copy, "x") == 0)
        {
            return copy;
        }
        else
        {
            copy.find("x") => int idx;
            copy.substring(0, idx) => string prefix;
            prefix.rfind(" ") => int left_bound;
            copy.substring(left_bound + 1, idx - left_bound - 1) => string token;

            findIntFromIndex(copy, idx + 1) => int n_repeats;

            // Repeat the bracketed sequence n times
            " " => string output;
            for(int i; i < n_repeats; i++)
            {
                output.insert(output.length()-1, token);
                output.insert(output.length()-1, " ");
            }
            idx - left_bound + Std.itoa(n_repeats).length() => int pattern_length;
            copy.replace(left_bound + 1, pattern_length, output.rtrim());

            return expand_tokens(copy);
        }
    }

    @doc "(hidden)"
    fun static string expand_repeats(string input)
    {
        return expand_tokens(expand_sequences(input));
    }

    // Pad pitch array to match length
    @doc "(hidden)"
    fun static int[][] pad_length(int array[][], int length, int pad_value[])
    {
        int output[0][0];

        for(int i; i < length; i++)
        {
            if(array.size() > i)
            {
                output << array[i];
            }
            else
            {
                output << pad_value;
            }
        }
        return output;
    }

    // Pad rhythm array to match length
    @doc "(hidden)"
    fun static float[] pad_length(float array[], int length, float pad_value)
    {
        float output[0];

        for(int i; i < length; i++)
        {
            if(array.size() > i)
            {
                output << array[i];
            }
            else
            {
                output << pad_value;
            }
        }
        return output;
    }

    // Pad velocity array to match length
    @doc "(hidden)"
    fun static int[] pad_length(int array[], int length, int pad_value)
    {
        int output[0];

        for(int i; i < length; i++)
        {
            if(array.size() > i)
            {
                output << array[i];
            }
            else
            {
                output << pad_value;
            }
        }
        return output;
    }

    //--------------------------------------------------------
    // Pitch related functions
    //--------------------------------------------------------

    // midi note to pitch
    @doc "(hidden)"
    ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"] @=> static string chromatic[];

    @doc "Convert a MIDI note number to a pitch name."
    fun static string mid2str(int note)
    {
        if(note < 0)
        {
            return "rest";
        }
        else
        {
            note % 12 => int step;
            ((note - step) / 12 ) - 1 => int octave;
            chromatic[step] => string name;
            name + Std.itoa(octave) => name;

            return name;
        }
    }

    @doc "Convert a pitch name to a MIDI note number."
    fun static int str2mid(string note)
    {
        int step;
        int alter;
        int octave;

        [0, 2, 4, 5, 7, 9, 11] @=> int steps[];
        ["c", "d", "e", "f", "g", "a", "b"] @=> string names[];
        int pitch_map[0];

        for(int i; i < names.size(); i++)
        {
            steps[i] => pitch_map[names[i]];
        }

        if(note.length() == 0)
        {
            <<<"ERROR: empty input given">>>;
            return 0;
        }
        if(!pitch_map.isInMap(note.substring(0,1).lower()))
        {
            <<<"ERROR: First character must be a valid pitch step (e.g. 'a', 'b', 'c')">>>;
            return 0;
        }
        else
        {
            pitch_map[note.substring(0,1)] => step;
        }
        if(note.length() <= 1)
        {
            return step;
        }
        else
        {
            note.substring(1) => string suffix;

            // Accidental handling
            if(suffix.find("s") != -1 || suffix.find("#") != -1)
            {
                countSubstring(suffix, "s") => int num_s;
                countSubstring(suffix, "#") => int num_sharp;

                num_s + num_sharp => alter;
            }
            if(suffix.find("f") != -1 || suffix.find("b") != -1)
            {
                countSubstring(suffix, "f") => int num_f;
                countSubstring(suffix, "b") => int num_flat;

                -1 * (num_f + num_flat) => alter;
            }
            if(suffix.find("n") != -1)
            {
                0 => alter;
            }

            // Octave handling
            if(findInt(suffix) != -1)
            {
                findIntFromIndex(suffix, findInt(suffix)) => octave;
            }

            return step + alter + 12 * (octave + 1);
        }
        
    }

    @doc "(hidden)"
    fun static int isKeySigToken(string input)
    {
        if(input.length() == 3 && input.substring(0, 1) == "k")
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }

    @doc "(hidden)"
    fun static int isPitchToken(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("abcdefg0123456789udfsb#nrk:".find(input.substring(i, 1).lower()) == -1)
            {
                return 0;
            }
        }
        return 1;
    }

    @doc "(hidden)"
    fun static int isRhythmToken(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("seqhwt0123456789/.".find(input.substring(i, 1).lower()) == -1)
            {
                return 0;
            }
        }
        return 1;
    }

    @doc "(hidden)"
    fun static int isVelocityToken(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("pfmv0123456789".find(input.substring(i, 1).lower()) == -1)
            {
                return 0;
            }
        }
        return 1;
    }

    @doc "(hidden)"
    fun static int isCCToken(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("c0123456789:".find(input.substring(i, 1).lower()) == -1)
            {
                return 0;
            }
        }
        return 1;
    }
}