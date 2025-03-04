//-----------------------------------------------------------------------------
// name: samplerInst.ck
// desc: This ezInstrument reads in an audio file and plays it back, repitched 
// according to incoming ezNote pitches. It assumes the audio file is a one-shot
// sample with a "root note" pitch. 
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

@import "smuck"

public class samplerInst extends ezInstrument
{
    // Set up signal chain
    16 => int _n_voices;
    SndBuf bufs[_n_voices] => outlet;

    // Private variables
    string _filename;
    int _root;

    // Constructor
    fun sampleInst(string file)
    {
        filename(file);
    }

    // Set filename
    fun void filename(string filename)
    {
        filename => _filename;
        for(auto buf : bufs)
        {
            buf.read(_filename);
            buf.pos(buf.samples());
        }
    }

    // Get filename
    fun string filename()
    {
        return _filename;
    }

    // Set root note
    fun void root(int root)
    {
        root => _root;
    }

    // Get root note
    fun int root()
    {
        return _root;
    }

    // Convert semitone offset to frequency ratio for playback rate
    fun float transpose(int amount)
    {
        return Math.pow(2, amount / 12.0);
    }


    // Note on function
    fun void noteOn(ezNote note, int voice)
    {
        <<<"noteOn", voice, note.pitch()>>>;
        transpose((note.pitch() $ int) - _root) => bufs[voice].rate;
        note.velocity() => bufs[voice].gain;
        bufs[voice].pos(0);
    }

    // Note off function
    fun void noteOff(ezNote note, int voice)
    {
        // Unused
    }

}