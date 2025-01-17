public class smUtils
{
    //--------------------------------------------------------
    // String utility functions
    //--------------------------------------------------------

    // Split a string by given delimiter, return array of split elements
    fun static string[] split(string input, string delim)
    {
        string output[0];
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
    fun static int count_substring(string input, string target)
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
    fun static int find_int_from_index(string input, int index)
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
    fun static string handle_sequence(string input)
    {
        input => string copy;

        // get the innermost sequence
        copy.rfind("[") => int left_bound;
        copy.find("]") => int right_bound;
        right_bound - left_bound - 1 => int seq_length;
        copy.substring(left_bound + 1, seq_length) => string sequence;

        find_int_from_index(copy, right_bound + 2) => int n_repeats;

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
    fun static string expand_sequences(string input)
    {
        input => string copy;

        if(count_substring(copy, "[") == 0 && count_substring(copy, "]") == 0)
        {
            return copy;
        }
        else
        {
            // Check to see if left/right bracket counts match
            if(count_substring(copy, "[") != count_substring(copy, "]"))
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

    fun static string expand_tokens(string input)
    {
        input => string copy;

        if(count_substring(copy, "x") == 0)
        {
            return copy;
        }
        else
        {
            copy.find("x") => int idx;
            copy.substring(0, idx) => string prefix;
            prefix.rfind(" ") => int left_bound;
            copy.substring(left_bound + 1, idx - left_bound - 1) => string token;

            find_int_from_index(copy, idx + 1) => int n_repeats;

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

    fun static string expand_repeats(string input)
    {
        return expand_tokens(expand_sequences(input));
    }

    //--------------------------------------------------------
    // Pitch related functions
    //--------------------------------------------------------

    // midi note to pitch
    ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"] @=> static string chromatic[];
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

    fun static int isPitchToken(string input)
    {
        for(int i; i < input.length(); i++)
        {
            if("abcdefg0123456789udfsb#r".find(input.substring(i, 1).lower()) == -1)
            {
                return 0;
            }
        }
        return 1;
    }

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