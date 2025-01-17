@import "smUtils.ck"

public class smRhythm
{
    //--------------------------------------------------------
    // SmMuCkish Rhythm Parsing
    //--------------------------------------------------------

    // Duration symbol map
    ["s", "e", "q", "h", "w"] @=> static string durationLabels[];
    [.25, .5, 1.0, 2.0, 4.0] @=> static float durationVals[];
    static float durationMap[5];

    // Parse duration value from single string token
    fun static float parse_duration(string input)
    {
        0 => int dots;
        0 => int isTriplet;
        1 => int tupletDenom;
        float value;

        if(!durationMap.isInMap("s"))
        {
            for (int i; i< durationVals.size(); i++)
            {
                durationVals[i] => durationMap[durationLabels[i]];
            }
        }

        if(Std.atof(input) != 0)
        {
            Std.atof(input) => value;
        }

        else
        {
            for(int i; i < input.length(); i++)
            {
                input.substring((i,1)) => string curr;
                if(curr == "t")
                {
                    1 => isTriplet;
                }
                if(curr == "/" &&  Std.atoi(input.substring((i+1,1))) != 0)
                {
                    Std.atoi(input.substring((i+1,1))) => tupletDenom;
                }        
                if(curr == ".")
                {
                    dots++;
                }
                if(durationMap.isInMap(curr))
                {
                    durationMap[curr] => value;
                }
            }
            if(isTriplet == 1)
            {
                value * 2/3 => value;
            }
            0 => float add;
            while(dots > 0)
            {
                Math.pow(.5, dots) * value +=> add;
                dots--;
            }
            add +=> value;
        }

        return value/tupletDenom;

    }

    fun static float[] parse_tokens(string tokens[])
    {
        float output[0];

        for(int i; i < tokens.size(); i++)
        {
            // handle ties -- add to previous duration
            if(tokens[i].find("_") != -1)
            {
                parse_duration(tokens[i].substring(1)) +=> output[-1];
            }
            // add to rhythm array
            else
            {
                output << parse_duration(tokens[i]);
            }
        }
        return output;
    }

    // Parse a SMuCkish rhythm string into an array of float values representing beats
    fun static float[] parse_rhythm(string input)
    {
        float output[0];

        // Expand all repeated sequences and tokens
        smUtils.expand_repeats(input) => string expanded;
        smUtils.split(expanded) @=> string tokens[];

        for(int i; i < tokens.size(); i++)
        {
            // handle ties -- add to previous duration
            if(tokens[i].find("_") != -1)
            {
                parse_duration(tokens[i].substring(1)) +=> output[-1];
            }
            // add to rhythm array
            else
            {
                output << parse_duration(tokens[i]);
            }
        }
        
        return output;
    }
}
