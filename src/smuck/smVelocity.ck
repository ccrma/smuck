@import "smUtils.ck"

public class smVelocity
{
    ["pppp", "ppp", "pp", "p", "mp", "mf", "f", "ff", "fff", "ffff"] @=> static string vel_labels[];
    // [1, 8, 24, 40, 56, 72, 88, 104, 120, 127] @=> static int vel_vals[];
    [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0] @=> static float vel_vals[];
    static float vel_map[10];

    fun static float parse_velocity(string input)
    {
        // Initialize associative velocity map
        for(int i; i < vel_labels.size(); i++)
        {
            vel_vals[i] => vel_map[vel_labels[i]];
        }

        // If value is a float, return it
        if(Std.atof(input) != 0)
        {
            // <<<"Plain number given: " + Std.atoi(input) >>>;
            if(Std.atof(input) > 1.0 || Std.atof(input) < 0.0)
            {
                <<<"WARNING: Received a velocity value outside the range 0.0-1.0. Velocity values outside this range will be clamped. Received: " + input>>>;
                return Std.clampf(Std.atof(input), 0.0, 1.0);
            }
            return Std.atof(input);
        }

        // If value is a symbol, return associated velocity value from map
        if(vel_map.isInMap(input))
        {
            // <<< "Found in map: " + input + " => " + vel_map[input] >>>;
            return vel_map[input];
        }

        // Handle velocity values prefixed with "v"
        if(input.find("v") != -1 && input.find("v") != input.length() - 1)
        {
            input.substring(input.find("v") + 1) => string vel_label;
            if(Std.atof(vel_label) != 0)
            {
                if(Std.atof(vel_label) > 1.0 || Std.atof(vel_label) < 0.0)
                {
                    <<<"WARNING: Received a velocity value outside the range 0.0-1.0. Velocity values outside this range will be clamped. Received: " + input>>>;
                    return Std.clampf(Std.atof(vel_label), 0.0, 1.0);
                }
                return Std.atof(vel_label);
            }
            else
            {
                if(vel_label != "0" && vel_label != "0.0" && vel_label != ".0" && vel_label != ".00")
                {
                    <<<"ERROR: Not a valid velocity value. Velocity must be a float value between 0.0 and 1.0. Received: " + input>>>;
                }
                return 0;
            }
        }

        // If no valid velocity value is found, return 0
        <<< "ERROR: Not a valid velocity value. Received: " + input >>>;
        return 0;
    }

    fun static float[] parse_tokens(string tokens[])
    {
        float output[0];

        for(int i; i < tokens.size(); i++)
        {
            output << parse_velocity(tokens[i]);
        }

        return output;
    }
    
    fun static float[] parse_velocities(string input)
    {
        float output[0];
        // Expand all repeated sequences and tokens
        smUtils.expand_repeats(input) => string expanded;
        smUtils.split(expanded) @=> string tokens[];

        for(int i; i < tokens.size(); i++)
        {
            // <<< tokens[i] >>>;
            output << parse_velocity(tokens[i]);
        }

        return output;
    }   
}