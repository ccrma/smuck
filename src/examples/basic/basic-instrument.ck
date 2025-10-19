//-----------------------------------------------------------------------------
// name: basic-instrument.ck
// desc: this example shows how to design a basic instrument and set it up for playback
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/), Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

// Create instrument(s) for playback
class basicInst extends ezInstrument
{
    // Set up signal chain
    //--------------------------------
    numVoices(10); // Allocate 10 voice polyphony for this instrument. Note: calling this function is important to tell the score player how many voices are available during playback
    SinOsc oscs[numVoices()];
    Gain g => outlet;                       // Chucking to outlet lets us connect our instrument to other signal chains after instantiation
    g.gain(0.1);
    for (0 => int i; i < numVoices(); i++)
    {
        oscs[i].gain(0);          // We want each osc to be silent before a note is played
        oscs[i] => g;
    }
    
    // Implement required noteOn and noteOff functions
    //--------------------------------

    // What our instrument does when a note is played (this function is called automatically by the score player)
    fun void noteOn(ezNote note, int voice) // noteOn and noteOff must have these arguments!
    {
        Std.mtof(note.pitch()) => oscs[voice].freq; // pitches are MIDI note numbers (e.g. 60 is middle C)
        note.velocity() => oscs[voice].gain; // ezNote velocities are float values 0.0-1.0
    }

    // What our instrument does when a note is released (this function is called automatically by the score player)
    fun void noteOff(ezNote note,int voice)
    {
        0 => oscs[voice].gain;
    }
}

// Create simple score
ezPart part0("a3 b c d e f g a");
ezPart part1("c5 d e f g a b c");
ezScore score;
score.add([part0, part1]);

// Create our instruments (1 for each part)
basicInst bass => dac;
basicInst treble => dac;

// Set the instruments for each part
ezScorePlayer player(score);
player.instruments([bass, treble]);

// Play the score
player.play();

// Let time pass until the score is finished playing
score.duration() => now;