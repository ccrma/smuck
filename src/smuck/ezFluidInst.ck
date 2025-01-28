@doc "ezInstrument that uses the FluidSynth chugin to play back ezScore data with FluidSynth SoundFont files. By default, uses the 'TimGM6mb.sf2' file which ships with SMucK. Note: using this instrument requires the FluidSynth chugin to be installed. See full class definition at https://github.com/smuck/smuck/blob/main/src/smuck/ezFluidInst.ck"
public class ezFluidInst extends ezInstrument
{
    @doc "(hidden)"
    FluidSynth fs => outlet;
    
    @doc "(hidden)"
    "./TimGM6mb.sf2" => string _filename;

    @doc "(hidden)"
    0 => int _instrument;

    @doc "Create a new ezFluidInst. By default, uses the 'TimGM6mb.sf2' SoundFont file (which ships with SMucK) and program 0 (Acoustic Grand Piano)."
    fun ezFluidInst()
    {
        fs.open(_filename);
        fs.progChange(_instrument);
    }
    @doc "Create a new ezFluidInst with a specific instrument program number"
    fun ezFluidInst(int instrument)
    {
        instrument => _instrument;
        fs.progChange(_instrument);
    }

    @doc "Create a new ezFluidInst with a specific SoundFont file"
    fun ezFluidInst(string filename)
    {
        filename => _filename;
        fs.open(_filename);
    }

    @doc "Create a new ezFluidInst with a specific SoundFont file and instrument program number"
    fun ezFluidInst(string filename, int instrument)
    {
        filename => _filename;
        instrument => _instrument;
        fs.open(_filename);
        fs.progChange(_instrument);
    }

    @doc "Set the SoundFont file to use"
    fun void filename(string filename)
    {
        filename => _filename;
        fs.open(_filename);
    }

    @doc "Get the SoundFont file currently in use"
    fun string filename()
    {
        return _filename;
    }

    @doc "Set the instrument program number to use"
    fun void instrument(int instrument)
    {
        instrument => _instrument;
        fs.progChange(_instrument);
    }

    @doc "Get the instrument program number currently in use"
    fun int instrument()
    {
        return _instrument;
    }

    @doc "Send a noteOn message to the FluidSynth instrument"
    fun void noteOn(ezNote theNote, int voice)
    {
        fs.noteOn(theNote.pitch(), theNote.velocity(), 0);
    }

    @doc "Send a noteOff message to the FluidSynth instrument"
    fun void noteOff(ezNote theNote, int voice)
    {
        fs.noteOff(theNote.pitch(), 0);
    }
}