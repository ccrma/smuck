@import "FluidSynth"

@doc "ezInstrument that uses the FluidSynth chugin to play back ezScore data with FluidSynth SoundFont files. NOTE: using this instrument requires the FluidSynth chugin to be installed. It is not imported by default. If you have the FluidSynth chugin installed, you can import smuck/ezFluidInst.ck to use this class"
public class ezFluidInst extends ezInstrument
{
    @doc "(hidden)"
    FluidSynth fs => outlet;
    
    @doc "(hidden)"
    // "./TimGM6mb.sf2" => 
    string _filename;

    @doc "(hidden)"
    0 => int _instrument;

    @doc "Create a new ez-fluidsynth instrument; (hint: use .open() to load a SoundFont file; use .progChange() to set an instrument)"
    fun ezFluidInst()
    { }

    @doc "Create a new ezFluidInst with a specific SoundFont file; program number will default to 0 (Grand Piano)"
    fun ezFluidInst(string filename)
    {
        filename => _filename;
        fs.open(_filename);
        fs.progChange(_instrument);
    }

    @doc "Create a new ezFluidInst with a specific SoundFont file and instrument program number"
    fun ezFluidInst(string filename, int instrument)
    {
        filename => _filename;
        instrument => _instrument;
        fs.open(_filename);
        fs.progChange(_instrument);
    }

    @doc "Load a SoundFont file to use"
    fun string open( string filename )
    {
        filename => _filename;
        fs.open(_filename);
        return _filename;
    }

    @doc "Get the SoundFont file currently in use"
    fun string filename()
    {
        return _filename;
    }

    @doc "Set the instrument program number to use"
    fun int progChange(int instrument)
    {
        instrument => _instrument;
        fs.progChange(_instrument);
        return instrument;
    }

    @doc "Get the instrument program number currently in use"
    fun int progChange()
    {
        return _instrument;
    }

    @doc "Send a noteOn message to the FluidSynth instrument"
    fun void noteOn(ezNote note, int voice)
    {
        fs.noteOn(note.pitch() $ int, (note.velocity() * 127) $ int, 0);
    }

    @doc "Send a noteOff message to the FluidSynth instrument"
    fun void noteOff(ezNote note, int voice)
    {
        fs.noteOff(note.pitch() $ int, 0);
    }
}