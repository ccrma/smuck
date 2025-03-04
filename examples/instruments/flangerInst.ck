//-----------------------------------------------------------------------------
// name: flangerInst.ck
// desc: This ezInstrument reads in an audio file and plays it back, repitched 
// according to incoming ezNote pitches. It assumes the audio file is a one-shot
// sample with a "root note" pitch. It also applies a flanger effect using comb filtering.
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

@import "/Users/alexhan/Desktop/ChucK/smuck/src/smuck.ck"

// This ezInstrument repitches one-shot audio samples and applies a flanger effect using comb filtering
public class flangerInst extends ezInstrument
{
    // Signal Chain
    // ---------------------------------------
    8 => int _n_voices;
    setVoices(_n_voices);
    SndBuf bufs[_n_voices] => Gain dry => outlet;
    SinOsc lfo => blackhole;

    bufs => DelayL del => Gain wet => outlet;
    1::second => del.max;

    // Private variables
    // ---------------------------------------
    // Audio file to be loaded
    string _filename;
    // Pitch of the audio sample (assumed to be one-shot)
    int _root;

    // LFO frequency
    1.6 => float _freq;
    lfo.freq(_freq);
    // LFO mod depth
    .5 => float _depth;
    // Dry/Wet mix
    .9 => float _mix;

    // Base delay
    6::ms => dur _base;
    // Modulation delay
    2::ms => dur _mod;


    // Constructor
    // ---------------------------------------
    fun flangerInst(string file)
    {
        filename(file);
    }

    // Get/Set functions
    // ---------------------------------------
    // Set the filename of the audio sample
    fun void filename(string filename)
    {
        filename => _filename;
        for(auto buf : bufs)
        {
            buf.read(_filename);
            buf.pos(buf.samples());
        }
    }

    // Get the filename of the audio sample
    fun string filename()
    {
        return _filename;
    }

    // Set the root note of the audio sample
    fun void root(int root)
    {
        root => _root;
    }

    // Get the root note of the audio sample
    fun int root()
    {
        return _root;
    }

    // Set the LFO frequency
    fun void freq(float val)
    {
        val => _freq;
        lfo.freq(_freq);
    }

    // Get the LFO frequency
    fun float freq()
    {
        return _freq;
    }

    // Set the LFO mod depth
    fun void depth(float val)
    {
        val => _depth;
    }

    // Get the LFO mod depth
    fun float depth()
    {
        return _depth;
    }

    // Set the dry/wet mix
    fun void mix(float val)
    {
        val => _mix;
        _mix => wet.gain;
        1.0 - _mix => dry.gain;
    }

    // Get the dry/wet mix
    fun float mix()
    {
        return _mix;
    }

    // Set the base delay
    fun void base(dur val)
    {
        val => _base;
    }

    // Get the base delay
    fun dur base()
    {
        return _base;
    }

    // Set the modulation delay
    fun void mod(dur val)
    {
        val => _mod;
    }

    // Get the modulation delay
    fun dur mod()
    {
        return _mod;
    }
    
    // Helper functions
    // ---------------------------------------
    fun float transpose(int amount)
    {
        return Math.pow(2, amount / 12.0);
    }

    // LFO driver
    fun void lfoDriver()
    {
        while(true)
        {
            (_base + (lfo.last() * _mod)) * _depth => del.delay;
            1::ms => now;
        }
    }

    // Automaticall spork the LFO driver
    spork~lfoDriver();

    
    // Note functions called by player
    // ---------------------------------------
    fun void noteOn(ezNote theNote, int which)
    {
        transpose((theNote.pitch() - _root) $ int) => bufs[which].rate;
        theNote.velocity() => bufs[which].gain;
        bufs[which].pos(0);
    }

    fun void noteOff(ezNote theNote,int which)
    {
        // Unused
    }

}

