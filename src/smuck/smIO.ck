@import {"ezScore.ck", "HashMap"}

// This is the class for reading from / writing to a JSON file
@doc "(hidden)"
public class SaveHandler {
    ".json" => static string EXTENSION;

    @doc "(hidden)"
    fun static void save(string filePath, HashMap data) {
        FileIO file;

        // Check if `.json` is included, if not, append it
        if (filePath.substring(filePath.length() - SaveHandler.EXTENSION.length()) != SaveHandler.EXTENSION) {
            filePath + SaveHandler.EXTENSION => filePath;
        }

        <<< "Saving to: ", filePath >>>;
        file.open(filePath, FileIO.WRITE);

        if (!file.good()) {
            <<< "Failed to open file: ", filePath >>>;
            return;
        }

        // Write to primary hashmap
        data.toJson() => string jsonData;

        // Write to file
        file <= jsonData;

        // Close file
        file.close();
    }

    @doc "(hidden)"
    fun static HashMap load(string filePath) {
        <<< "Loading from: ", filePath >>>;
        HashMap.fromJsonFile(filePath) @=> HashMap data;
        return data;
    }
}

@doc "Class for reading/writing ezScore objects to/from JSON files. Requires HashMap chugin."
public class smIO
{
    @doc "(hidden)"
    fun static HashMap hashFloatArray(float array[])
    {
        HashMap hm;

        for(int i; i < array.size(); i++)
        {
            hm.set(i, array[i]);
        }

        return hm;
    }

    @doc "(hidden)"
    fun static float[] unHashFloatArray(HashMap hm)
    {
        float array[0];
        if (hm == null) return array;

        for(int i; i < hm.size(); i++)
        {
            array << hm.getFloat(i);
        }

        return array;
    }

    @doc "(hidden)"
    fun static HashMap hashNote(ezNote note)
    {
        HashMap hm;

        hm.set("onset", note.onset());
        hm.set("beats", note.beats());
        hm.set("pitch", note.pitch());
        hm.set("velocity", note.velocity());
        hm.set("isRest", note.isRest());
        hm.set("text", note.text());
        hm.set("data", hashFloatArray(note.data()));

        return hm;
    }

    @doc "(hidden)"
    fun static ezNote unHashNote(HashMap hm)
    {
        ezNote note;
        hm.getFloat("onset") => note.onset;
        hm.getFloat("beats") => note.beats;
        hm.getFloat("pitch") => note.pitch;
        hm.getFloat("velocity") => note.velocity;
        hm.getInt("isRest") => note.isRest;
        hm.getStr("text") => note.text;
        unHashFloatArray(hm.get("data")) => note.data;
        return note;
    }

    @doc "(hidden)"
    fun static HashMap hashCC(ezCC cc)
    {
        HashMap hm;
        hm.set("command", cc.command());
        hm.set("channel", cc.channel());
        hm.set("data1", cc.data1());
        hm.set("data2", cc.data2());
        hm.set("onset", cc.onset());
        return hm;
    }

    @doc "(hidden)"
    fun static ezCC unHashCC(HashMap hm)
    {
        hm.getInt("command") => int command;
        hm.getInt("channel") => int channel;
        hm.getInt("data1") => int data1;
        hm.getInt("data2") => int data2;
        hm.getFloat("onset") => float onset;
        ezCC cc(command, channel, data1, data2, onset);
        return cc;
    }

    @doc "(hidden)"
    fun static HashMap hashMeasure(ezMeasure measure)
    {
        HashMap hm;

        HashMap hnotes;
        for(int i; i < measure.notes().size(); i++)
        {
            hashNote(measure.notes()[i]) @=> HashMap hnote;
            hnotes.set(i, hnote);
        }

        hm.set("notes", hnotes);

        HashMap hccs;
        for(int i; i < measure.ccs().size(); i++)
        {
            hashCC(measure.ccs()[i]) @=> HashMap hcc;
            hccs.set(i, hcc);
        }
        hm.set("ccs", hccs);

        hm.set("onset", measure.onset());
        // hm.set("beats", measure.beats());
        // hm.set("polyphony", measure.polyphony());
        hm.set("text", measure.text());

        return hm;
    }

    @doc "(hidden)"
    fun static ezMeasure unHashMeasure(HashMap hm)
    {
        ezMeasure measure;
        ezNote notes[0];

        hm.get("notes") @=> HashMap hnotes;
        if (hnotes == null) return measure;

        for(int i; i < hnotes.size(); i++)
        {
            unHashNote(hnotes.get(i)) @=> ezNote note;
            notes << note;
        }

        measure.notes(notes);

        ezCC ccs[0];
        if (hm.get("ccs") != null)
        {
            hm.get("ccs") @=> HashMap hccs;
            for(int i; i < hccs.size(); i++)
            {
                unHashCC(hccs.get(i)) @=> ezCC cc;
                ccs << cc;
            }
            measure.ccs(ccs);
        }

        hm.getFloat("onset") => measure.onset;
        // hm.getFloat("beats") => measure.beats;
        // hm.getInt("polyphony") => measure.polyphony;
        hm.getStr("text") => measure.text;

        measure.sort();

        return measure;
    }

    @doc "(hidden)"
    fun static HashMap hashPart(ezPart part)
    {
        HashMap hm;

        HashMap hmeasures;
        for(int i; i < part.measures().size(); i++)
        {
            hashMeasure(part.measures()[i]) @=> HashMap hmeasure;
            hmeasures.set(i, hmeasure);
        }

        hm.set("measures", hmeasures);
        hm.set("text", part.text());

        return hm;
    }

    @doc "(hidden)"
    fun static ezPart unHashPart(HashMap hm)
    {
        ezMeasure measures[0];

        hm.get("measures") @=> HashMap hmeasures;
        if (hmeasures == null) return new ezPart;

        for(int i; i < hmeasures.size(); i++)
        {
            unHashMeasure(hmeasures.get(i)) @=> ezMeasure measure;
            measures << measure;
        }

        ezPart part(measures);
        hm.getStr("text") => part.text;
        
        return part;
    }

    @doc "(hidden)"
    fun static HashMap hashScore(ezScore score)
    {
        HashMap hm;

        HashMap hparts;
        for(int i; i < score.parts().size(); i++)
        {
            hashPart(score.parts()[i]) @=> HashMap hpart;
            hparts.set(i, hpart);
        }

        hm.set("parts", hparts);
        hm.set("bpm", score.bpm());
        hm.set("text", score.text());
        return hm;
    }

    @doc "(hidden)"
    fun static ezScore unHashScore(HashMap hm)
    {
        hm.get("parts") @=> HashMap hparts;
        if (hparts == null) return new ezScore;

        ezPart parts[0];
        for(int i; i < hparts.size(); i++)
        {
            unHashPart(hparts.get(i)) @=> ezPart part;
            parts << part;
        }

        ezScore score(parts);
        hm.getFloat("bpm") => score.bpm;
        hm.getStr("text") => score.text;

        return score;
    }

    @doc "Save an ezScore object to a JSON file, specifying the filepath. Requires HashMap chugin."
    fun static void scoreToJson(string filepath, ezScore score)
    {
        if(filepath != null)
        {
            chout <= "Saving ezScore to: " <= filepath <= IO.newline();
            SaveHandler.save(filepath, hashScore(score));
        }
        else
        {
            cherr <= "No filepath provided";
        }
    }

    @doc "Save an ezScore object to a JSON file, opening a file dialog to select the filepath"
    fun static void scoreToJson(ezScore score)
    {
        GG.saveFileDialog(null) => string filepath;
        if(filepath != null)
        {
            chout <= "Saving ezScore to: " <= filepath <= IO.newline();
            SaveHandler.save(filepath, hashScore(score));
        }
        else
        {
            cherr <= "No filepath provided";
        }
    }

    @doc "Load an ezScore object from a JSON file, specifying the filepath. Requires HashMap chugin. Returns empty ezScore if file not found or malformed."
    fun static ezScore jsonToScore(string filepath)
    {
        chout <= "Loading ezScore from: " <= filepath <= IO.newline();
        SaveHandler.load(filepath) @=> HashMap data;
        if(data != null)
        {
            return unHashScore(data);
        }
        else
        {
            cherr <= "Failed to load ezScore from: " <= filepath <= IO.newline();
            return new ezScore;
        }
    }

    @doc "Load an ezScore object from a JSON file, opening a file dialog to select the filepath"
    fun static ezScore jsonToScore()
    {
        GG.openFileDialog(null) => string filepath;
        if(filepath != null)
        {
            return jsonToScore(filepath);
        }
        else
        {
            cherr <= "No filepath provided";
            return new ezScore;
        }
    }
}
