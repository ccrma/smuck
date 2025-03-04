//-----------------------------------------------------------------------------
// name: basic-instrument.ck
// desc: this example shows how to design a basic instrument and set it up for playback
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/), Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------
@import "smuck"

// Create instrument(s) for playback
class basicInst extends ezInstrument
{
    // Set up signal chain
    //--------------------------------

    // How many voices our instrument has (for polyphony)
    10 => int n_voices;
    setVoices(n_voices); // Note: calling this function is important to tell the score player how many voices are available during playback
    SinOsc oscs[n_voices];
    Gain g => outlet;                       // Chucking to outlet lets us connect our instrument to other signal chains after instantiation
    g.gain(0.1);
    for (0 => int i; i < n_voices; i++)
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
ezScore score();
score.addPart(part0);
score.addPart(part1);

// Create our instruments (1 for each part)
basicInst bass => dac;
basicInst treble => dac;

// Set the instruments for each part
ezScorePlayer player(score);
player.setInstrument([bass, treble]);

// Play the score
player.play();

// Let time pass until the score is finished playing
while(player.isPlaying())
{
    second => now;
}