@import "../../src/smuck.ck"

public class fluidInst extends ezInstrument
{
    FluidSynth fs => outlet;
    
    "../data/TimGM6mb.sf2" => string _filename;
    0 =>int _instrument;
    fs.open(_filename);
    fs.progChange(_instrument);

    fun fluidInst(int instrument)
    {
        instrument => _instrument;
        fs.progChange(_instrument);
    }

    fun fluidInst(string filename)
    {
        filename => _filename;
        fs.open(_filename);
    }

    fun fluidInst(string filename, int instrument)
    {
        filename => _filename;
        instrument => _instrument;
        fs.open(_filename);
        fs.progChange(_instrument);
    }

    fun void filename(string filename)
    {
        _filename = filename;
        fs.open(_filename);
    }

    fun string filename()
    {
        return _filename;
    }

    fun void instrument(int instrument)
    {
        _instrument = instrument;
        fs.progChange(_instrument);
    }

    fun int instrument()
    {
        return _instrument;
    }

    fun void noteOn(ezNote theNote, int voice)
    {
        fs.noteOn(theNote.pitch(), theNote.velocity(), 0);
    }

    fun void noteOff(ezNote theNote, int voice)
    {
        fs.noteOff(theNote.pitch(), 0);
    }
}