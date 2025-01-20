public class smScale
{
    int notes[];

    int pitch_dict[7];
    0 => pitch_dict["C"];
    2 => pitch_dict["D"];
    4 => pitch_dict["E"];
    5 => pitch_dict["F"];
    7 => pitch_dict["G"];
    9 => pitch_dict["A"];
    11 => pitch_dict["B"];

    int alter_dict[0];
    -1 => alter_dict["b"];
    1 => alter_dict["#"];

    int scaleDict[0][0];

    // major/minor
    [0, 2, 4, 5, 7, 9, 11] @=> scaleDict["major"];
    [0, 2, 3, 5, 7, 8, 10] @=> scaleDict["minor"];
    [0, 2, 3, 5, 7, 9, 11] @=> scaleDict["melodicminor"];
    [0, 2, 3, 5, 7, 8, 11] @=> scaleDict["harmoniccminor"];

    // greek modes
    [0, 2, 4, 5, 7, 9, 11] @=> scaleDict["ionian"];
    [0, 2, 3, 5, 7, 9, 10] @=> scaleDict["dorian"];
    [0, 1, 3, 5, 7, 8, 10] @=> scaleDict["phyrgian"];
    [0, 2, 4, 6, 7, 9, 11] @=> scaleDict["lydian"];
    [0, 2, 4, 5, 7, 9, 10] @=> scaleDict["mixolydian"];
    [0, 2, 3, 5, 7, 8, 10] @=> scaleDict["aeolian"];
    [0, 1, 3, 5, 6, 8, 10] @=> scaleDict["locrian"];

    // symmetric
    [0, 2, 4, 6, 8, 10] @=> scaleDict["wholetone"];
    [0, 3, 4, 7, 8, 11] @=> scaleDict["aug"];
    [0, 1, 3, 4, 6, 7, 9, 10] @=> scaleDict["halfwhole"];
    [0, 2, 3, 5, 6, 8, 9, 11] @=> scaleDict["wholehalf"];

    // penta/hexa
    [0, 3, 5, 6, 7, 10] @=> scaleDict["blues"];
    [0, 2, 4, 7, 9] @=> scaleDict["maj_pent"];
    [0, 3, 5, 7, 10] @=> scaleDict["min_pent"];
    [0, 2, 4, 7, 9, 11] @=> scaleDict["maj_hex"];
    [0, 2, 3, 5, 7, 10] @=> scaleDict["min_hex"];

    // altered modes
    [0, 2, 4, 5, 7, 8, 11] @=> scaleDict["maj_harm"];
    [0, 2, 3, 5, 7, 8, 11] @=> scaleDict["min_harm"];
    [0, 1, 4, 5, 7, 8, 10] @=> scaleDict["phry_dom"];
    [0, 2, 4, 6, 7, 9, 10] @=> scaleDict["lyd_dom"];
    [0, 2, 4, 6, 8, 9, 11] @=> scaleDict["lyd_aug"];
    [0, 2, 4, 5, 6, 8, 10] @=> scaleDict["maj_loc"];
    [0, 1, 3, 4, 6, 8, 10] @=> scaleDict["supraloc"];
    [0, 1, 3, 5, 7, 9, 11] @=> scaleDict["nea_maj"];
    [0, 1, 3, 5, 7, 8, 11] @=> scaleDict["nea_min"];
    [0, 2, 3, 5, 6, 8, 10] @=> scaleDict["half_dim"];

    // "exotic"
    [0, 1, 4, 5, 7, 8, 11] @=> scaleDict["dbl_harm"];
    [0, 1, 4, 6, 8, 10, 11] @=> scaleDict["enigmatic"];
    [0, 2, 3, 6, 7, 8, 10] @=> scaleDict["gypsy"];
    [0, 2, 3, 6, 7, 8, 11] @=> scaleDict["min_hung"];
    [0, 3, 4, 6, 7, 9, 10] @=> scaleDict["maj_hung"];
    [0, 1, 4, 5, 6, 8, 11] @=> scaleDict["persian"];
    [0, 2, 4, 6, 9, 10] @=> scaleDict["prometheus"];
    [0, 1, 5, 7, 8] @=> scaleDict["in"];
    [0, 1, 5, 7, 10] @=> scaleDict["insen"];
    [0, 1, 5, 6, 10] @=> scaleDict["iwato"];
    [0, 3, 5, 7, 10] @=> scaleDict["yo"];


    fun smScale(string name) 
    {
        scaleDict[name] @=> notes;
    }

    fun smScale(string name, int root) 
    {
        scaleDict[name] @=> notes;
        for(int i; i < notes.size(); i++)
        {
            root +=> notes[i];
        }
    }

    fun smScale(string name, string rootName) 
    {
        scaleDict[name] @=> notes;
        parseRoot(rootName) => int root;

        for(int i; i < notes.size(); i++)
        {
            root +=> notes[i];
        }
    }

    fun int parseRoot(string input)
    {
        int root;

        if(input.length() > 3)
        {
            <<<"poorly formatted input. String representing root should be max. 3 characters and have format 'step'+'alter'+'octave'">>>;
        }

        input.substring(0,1) => string step;
        if(pitch_dict.isInMap(step))
        {
            pitch_dict[step] => root;
        }
        else
        {
            <<<"Invalid root note (did you forget uppercase?)">>>;
            -999 => root;
        }        

        if(input.length() > 1)
        {
            if(alter_dict.isInMap(input.substring(1,1)))
            {
                alter_dict[input.substring(1,1)] +=> root;
            }
            if(Std.atoi(input.substring(1,1)) != -1)
            {
                Std.atoi(input.substring(1,1)) * 12 +=> root;
            }
            if(input.length() > 2 && Std.atoi(input.substring(2,1)) != -1)
            {
                Std.atoi(input.substring(2,1)) * 12 +=> root;
            }
        }

        return root;
    }

    fun int[] lookup(string name)
    {
        return scaleDict[name];
    }
    fun int[] lookup(string name, int root)
    {
        int ans[];
        scaleDict[name] @=> ans;
        for(int i; i < ans.size(); i++)
        {
            root +=> ans[i];
        }
        return ans;
    }
    fun int[] lookup(string name, string rootName)
    {
        int ans[];
        scaleDict[name] @=> ans;
        parseRoot(rootName) => int root;
        for(int i; i < ans.size(); i++)
        {
            root +=> ans[i];
        }
        return ans;
    }
    fun int degree(int note)
    {
        -1 => int ans;
        note % 12 => int pitch;
        for(int i; i < notes.size(); i++)
        {
            if(notes[i] % 12 == pitch)
            {
                i => ans;
            }
        }
        return ans;
    }
}