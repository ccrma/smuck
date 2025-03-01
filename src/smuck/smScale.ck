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
    [0, 2, 3, 5, 7, 9, 11] @=> scaleDict["melodic_minor"];
    [0, 2, 3, 5, 7, 8, 11] @=> scaleDict["harmonic_minor"];

    // greek modes
    [0, 2, 4, 5, 7, 9, 11] @=> scaleDict["ionian"];
    [0, 2, 3, 5, 7, 9, 10] @=> scaleDict["dorian"];
    [0, 1, 3, 5, 7, 8, 10] @=> scaleDict["phrygian"];
    [0, 2, 4, 6, 7, 9, 11] @=> scaleDict["lydian"];
    [0, 2, 4, 5, 7, 9, 10] @=> scaleDict["mixolydian"];
    [0, 2, 3, 5, 7, 8, 10] @=> scaleDict["aeolian"];
    [0, 1, 3, 5, 6, 8, 10] @=> scaleDict["locrian"];

    // symmetric
    [0, 2, 4, 6, 8, 10] @=> scaleDict["wholetone"];
    [0, 3, 4, 7, 8, 11] @=> scaleDict["augmented"];
    [0, 1, 3, 4, 6, 7, 9, 10] @=> scaleDict["half_whole"];
    [0, 2, 3, 5, 6, 8, 9, 11] @=> scaleDict["whole_half"];

    // penta/hexa
    [0, 3, 5, 6, 7, 10] @=> scaleDict["blues"];
    [0, 2, 4, 7, 9] @=> scaleDict["major_pentatonic"];
    [0, 3, 5, 7, 10] @=> scaleDict["minor_pentatonic"];
    [0, 2, 4, 7, 9, 11] @=> scaleDict["major_hexatonic"];
    [0, 2, 3, 5, 7, 10] @=> scaleDict["minor_hexatonic"];

    // altered modes
    [0, 2, 4, 5, 7, 8, 11] @=> scaleDict["major_harmonic"];
    [0, 2, 3, 5, 7, 8, 11] @=> scaleDict["minor_harmonic"];
    [0, 1, 4, 5, 7, 8, 10] @=> scaleDict["phrygian_dominant"];
    [0, 2, 4, 6, 7, 9, 10] @=> scaleDict["lydian_dominant"];
    [0, 2, 4, 6, 8, 9, 11] @=> scaleDict["lydian_augmented"];
    [0, 2, 4, 5, 6, 8, 10] @=> scaleDict["major_locrian"];
    [0, 1, 3, 4, 6, 8, 10] @=> scaleDict["supralocrian"];
    [0, 1, 3, 5, 7, 9, 11] @=> scaleDict["neapolitan_major"];
    [0, 1, 3, 5, 7, 8, 11] @=> scaleDict["neapolitan_minor"];
    [0, 2, 3, 5, 6, 8, 10] @=> scaleDict["half_diminished"];

    // "exotic"
    [0, 1, 4, 5, 7, 8, 11] @=> scaleDict["double_harmonic"];
    [0, 1, 4, 6, 8, 10, 11] @=> scaleDict["enigmatic"];
    [0, 2, 3, 6, 7, 8, 10] @=> scaleDict["gypsy"];
    [0, 2, 3, 6, 7, 8, 11] @=> scaleDict["hungarian_minor"];
    [0, 3, 4, 6, 7, 9, 10] @=> scaleDict["hungarian_major"];
    [0, 1, 4, 5, 6, 8, 11] @=> scaleDict["persian"];
    [0, 2, 4, 6, 9, 10] @=> scaleDict["prometheus"];
    [0, 1, 5, 7, 8] @=> scaleDict["in"];
    [0, 1, 5, 7, 10] @=> scaleDict["insen"];
    [0, 1, 5, 6, 10] @=> scaleDict["iwato"];
    [0, 3, 5, 7, 10] @=> scaleDict["yo"];


    fun smScale(string name) 
    {
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> notes;
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
        }
    }

    fun smScale(string name, int root) 
    {
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> notes;
            for(int i; i < notes.size(); i++)
            {
                root +=> notes[i];
            }
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
        }
    }

    fun smScale(string name, string rootName) 
    {
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> notes;
            parseRoot(rootName) => int root;

            for(int i; i < notes.size(); i++)
            {
                root +=> notes[i];
            }
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
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
        int ans[];
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> ans;
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
        }

        return ans;
    }
    fun int[] lookup(string name, int root)
    {
        int ans[];
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> ans;
            for(int i; i < ans.size(); i++)
            {
                root +=> ans[i];
            }
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
        }

        return ans;
    }
    fun int[] lookup(string name, string rootName)
    {
        int ans[];
        if(scaleDict.isInMap(name))
        {
            scaleDict[name] @=> ans;
            parseRoot(rootName) => int root;
            for(int i; i < ans.size(); i++)
            {
                root +=> ans[i];
            }
        }
        else
        {
            <<<"Invalid scale name. Received: " + name >>>;
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