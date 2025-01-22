// ------------------------------------------------------------------
// EZchord : Chord parser
// ------------------------------------------------------------------
// Enter chords as string, get MIDI note numbers out!
// Initialize the EZChord object with a chord name (string)
// parsing is done automatically upon initialization
// then, access member variables to get info about the chord. Most importantly,
// can get the MIDI note values for chord tones
//
// Input: a string, following conventional chord nomenclature
// Ex:
// "Gbmaj7#11" = "G" + "b" + "maj" + "7#11"
// this would correspond to notes Gb Bb Db F Ab C
//
// Member variables:
// notes (int[]) : MIDI note values for chord tones
// root (int) : the root note, as MIDI note
// rootName (str) : name of the root note, e.g. F, Ab, D##
// triad (int[]) : MIDI note values for the triad component of the chord
// triadType (str) : the triad type, e.g. "maj", "min", "dim"
// extension (int[]) : the MIDI note values for the extended (upper) chord tones from the 7th and above
// suffix (str) : the description of the extension type
//
//
// usage notes:
// input expects the format: pitch + accidental + triad + extension
// pitch is always 1 character, accidental is 0-2 characters, triad is 0 or 3 characters, extension is arbitrarily long
// some extensions assume the presence of unspecified extensions--in example above, Gbmaj7#11 assumes that the 9th (Ab) is also present
//
// 
// Alex Han 2023

public class smChord
{
    // static member variables
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

    int triad_dict[0][0];
    [0, 4, 7] @=> triad_dict["dom"];
    [0, 4, 7] @=> triad_dict["maj"];
    [0, 3, 7] @=> triad_dict["min"];
    [0, 4, 8] @=> triad_dict["aug"];
    [0, 3, 6] @=> triad_dict["dim"];
    [0, 5, 7] @=> triad_dict["sus"];
    
    int seventh_dict[0];
    10 => seventh_dict["dom"];
    11 => seventh_dict["maj"];
    10 => seventh_dict["min"];
    10 => seventh_dict["aug"];
    9  => seventh_dict["dim"];
    10 => seventh_dict["sus"];

    // initialization
    string input;

    // member variables
    int notes[];
    int root;
    string rootName;
    int triad[];
    string triadType;
    int extension[];
    string suffix;

    fun smChord(string in)
    {
        set(in);  
    }

    fun smChord(string in, int octave)
    {
        set(in);
        for(int i; i < notes.size(); i++)
        {
            (octave + 1) * 12 +=> notes[i];
        }
    }
    fun void set(string in)
    {
        in => input;
        setRoot();
        setTriad();
        setExtension();
        setNotes();
    }

    fun void set(string in, int octave)
    {
        in => input;
        setRoot();
        setTriad();
        setExtension();
        setNotes();
        for(int i; i < notes.size(); i++)
        {
            (octave + 1) * 12 +=> notes[i];
        }
    }
    fun void setRoot()
    {

        input => string raw;

        int root_temp;
        int alter;

        raw.substring(0,1) => string first;
        if(pitch_dict.isInMap(first.upper()))
        {
            pitch_dict[first] => root_temp;
            first => rootName;
        }
        else
        {
            <<<"Invalid root note">>>;
            -999 => root_temp;
        }
        raw.erase(0, 1);
        if(raw.length() > 0)
        {
            raw.substring(0,1) => string first;

            if(alter_dict.isInMap(first))
            {
                alter_dict[first] + alter => alter;
                raw.erase(0,1);
                if(alter_dict.isInMap(raw.substring(0,1)))
                {
                    alter_dict[first] + alter => alter;
                    raw.erase(0,1);
                }
            }
        }
        if (alter > 0)
        {
            for (int i; i < alter; i++)
            {
                "#" +=> rootName;
            }
        }
        if (alter < 0)
        {
            for (int i; i < alter*-1; i++)
            {
                "b" +=> rootName;
            }   
        }
        root_temp + alter => root;
    }

    fun void setTriad()
    {
        input => string raw;
        rootName.length() => int prefix;
        if(input.length() <= prefix) // i.e. there is nothing after the root characters
        {
            "maj" => triadType;
            "" => suffix;
        }
        else
        {
            raw.substring(prefix) => raw; // trimming the root characters from front
            if(raw.length() >= 3)
            {
                raw.substring(0,3) => string front;
                if(triad_dict.isInMap(front)) // the first 3 characters match "maj", "min", "dom" etc.
                {
                    front => triadType;
                    if(raw.length() > 3)
                    {
                        raw.substring(3) => suffix; // suffix becomes everything after the root + 3 characters
                    }
                    else
                    {
                        "" => suffix;
                    }
                }
                else // i.e. extended dom. seventh chords
                {
                    raw => suffix;
                    if(Std.atoi(raw.substring(0,1)) != -1) // the first character is some integer
                    {
                        "dom" => triadType;
                    }
                    else // something is strange, default to major
                    {
                        "maj" => triadType;
                    }
                }
            }
            if(raw.length() > 0 && raw.length() < 3) // i.e. extended dom. seventh chords
            {
                raw => suffix; // suffix becomes everything after root 
                if(Std.atoi(raw.substring(0,1)) != -1) // first character is some integer
                {
                    "dom" => triadType;
                }
                else // something is strange, default to major
                {
                    "maj" => triadType;
                }
            }
        }
        // set integer notes indicating kind of triad
        if(triad_dict.isInMap(triadType))
        {
            triad_dict[triadType] @=> triad;
        }
    }

    fun void setExtension()
    {
        int ans[0];
        0 => int alter;
        suffix => string input;
        while(input.length() > 0)
        {
            input.substring(0,1) => string first;
            // processing alteration symbol
            if(alter_dict.isInMap(first))
            {
                alter_dict[first] => alter;
                input.erase(0,1);
            }
            if(triadType == "min" && input.length() >= 3)
            {
                if(input.substring(0,3) == "7b5")
                {
                    // <<<"min7b5">>>;
                    "dim" => triadType;
                    triad_dict[triadType] @=> triad;
                    ans << seventh_dict["min"];
                    input.erase(0,3);
                }
                if (input.substring(0,3) == "9b5")
                {
                    // <<<"min9b5">>>;
                    "dim" => triadType;
                    triad_dict[triadType] @=> triad;
                    ans << seventh_dict["min"];
                    ans << 14;
                    input.erase(0,3);
                }
            }
            // special case -- maj7 explicitly specified 
            if(input.length() >= 4 && input.substring(0,4) == "Maj7")
            {
                // <<<"maj7">>>;
                ans << seventh_dict["maj"];
                input.erase(0,4);
            }
            // 6th defaults to major 6th above root
            if(input.length() > 0 && input.substring(0,1) == "6")
            {
                // <<<"6">>>;
                ans << 9 + alter;
                input.erase(0,1);
            }
            // 7th added depending on triad type
            if(input.length() > 0 && input.substring(0,1) == "7")
            {
                // <<<"7">>>;
                ans << seventh_dict[triadType];
                input.erase(0,1);
            }
            // 9th added; if no 7th was specified, adds implicit 7th based on triad
            if(input.length() > 0 && input.substring(0,1) == "9")
            {
                if(ans.size() == 0)
                {
                    ans << seventh_dict[triadType];
                }
                ans << 14 + alter;
                input.erase(0,1);
            }
            // 11th added; if no 7th was specified, adds implicit 7th and 9th based on triad
            if(input.length() >= 2 && input.substring(0,2) == "11")
            {
                if(ans.size() == 0)
                {
                    ans << seventh_dict[triadType];
                    ans << 14;
                }
                ans << 17 + alter;
                input.erase(0,2);
            }
            // 13th added; if no 7th was specified, adds implicit 7th and 9th based on triad. NOTE: does not assume 11th
            if(input.length() >= 2 && input.substring(0,2) == "13")
            {
                //<<<"adding 13th">>>;
                if(ans.size() == 0 && input.length() == 2)
                {
                    ans << seventh_dict[triadType];
                    ans << 14;
                }
                ans << 21 + alter;
                input.erase(0,2);
            }
        }
        ans @=> extension;
    }
    fun void setNotes()
    {
        int temp[0];
        for (int i; i < triad.size(); i++)
        {
            temp << root + triad[i];
        }
        if(extension.size() > 0)
        {
            for (int j; j < extension.size(); j++)
            {
                temp << root + extension[j];
            }
        }

        temp.sort();
        int ans[0];
        if(temp.size() > 0)
        {
            ans << temp[0];
        }
        else
        {
            ans << root;
        }
        for(1 => int k; k < temp.size(); k++)
        {
            if(temp[k] != temp[k-1])
            {
                ans << temp[k];
            }
        }
        ans @=> notes;
    }

    fun void inversion(int n)
    {
        n % notes.size() => n;
        for(int i; i < n; i++)
        {
            12 +=> notes[i];
        }
        notes.sort();
    }
}