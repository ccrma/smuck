@import "smUtils.ck"

public class smVelocity
{
    ["pppp", "ppp", "pp", "p", "mp", "mf", "f", "ff", "fff", "ffff"] @=> static string vel_labels[];
    [1, 8, 24, 40, 56, 72, 88, 104, 120, 127] @=> static int vel_vals[];
    static int vel_map[10];

    fun static int parse_velocity(string input)
    {
        // Initialize associative velocity map
        for(int i; i < vel_labels.size(); i++)
        {
            vel_vals[i] => vel_map[vel_labels[i]];
        }

        // If value is a number, return it
        if(Std.atoi(input) != 0)
        {
            // <<<"Plain number given: " + Std.atoi(input) >>>;
            return Std.atoi(input);
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
            if(Std.atoi(vel_label) != 0)
            {
                return Std.atoi(vel_label);
            }
            else
            {
                <<<"ERROR: Not a valid velocity value. Velocity must be a number between 0 and 127.">>>;
                return 0;
            }
        }

        // If no valid velocity value is found, return 0
        <<< "ERROR: Not a valid velocity value." >>>;
        return 0;
    }

    fun static int[] parse_velocities(string input)
    {
        int output[0];
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