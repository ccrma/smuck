@import "../../src/smuck.ck"

// @import "smuck"

int note_on_count;
int note_off_count;

// ========================== define instruments (sound patches) ==========================
class myInstrument extends ezInstrument
{
    // define sound chain
    8 => n_voices;              // define this for polyphonic instruments!
    SawOsc oscs[n_voices];
    ADSR envs[n_voices];
    Gain g => NRev rev => outlet;
    g.gain(.1);
    rev.mix(.01);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(4::ms, 20000::ms, 0.0, 200::ms);
    }

    // This function defines the note on behavior
    fun void noteOn(ezNote theNote, int voice)
    {
        Std.mtof(theNote.pitch) => oscs[voice].freq;
        (theNote.velocity / 127.0) => oscs[voice].gain;
        envs[voice].keyOn();
        // <<< "note on", voice >>>;
    }

    fun void noteOff(int voice)
    {
        envs[voice].keyOff();
        // <<< "note off", voice >>>;
    }

    fun void setNumVoices(int n)
    {
        n => n_voices;
        new SawOsc[n_voices] @=> oscs;
        new ADSR[n_voices] @=> envs;
        for(int i; i < n_voices; i++)
        {
            oscs[i] => envs[i] => g;
            envs[i].set(4::ms, 20000::ms, 0.0, 200::ms);
        }
    }
}

// ========================== run tests ==========================

fun void reset_test_vars()
{
    0 => note_on_count;
    0 => note_off_count;
}

fun void test_score_player(string midi_file)
{
    ezScore score;
    score.setTempo(120);
    score.setTimeSig(4, 4);
    score.importMIDI(midi_file);
    
    ezInstrument instruments[score.numParts()];
    Gain g => dac;

    for (int i; i < score.numParts(); i++)
    {
        new myInstrument() @=> instruments[i];
        instruments[i] => g;
    }

    <<< "instruments:", instruments.size() >>>;

    ezScorePlayer sp(score);
    5::ms => sp.tick;
    sp.setInstrument(instruments);

    sp.play();
    1 => sp.rate;
    score.getScoreDuration() * (1.0/sp.rate) => now;
}


4 => int n_tests;
"../data/" => string data_dir;

string test_midi[n_tests];
data_dir + "test1_poly8.mid" => test_midi[0];
data_dir + "test2_fastarp.mid" => test_midi[1];
data_dir + "test3_staircase.mid" => test_midi[2];
data_dir + "test4_layers.mid" => test_midi[3];

for (0 => int i; i < n_tests; i++)
{
    <<< "--------------------------------- running test", i, "---------------------------------" >>>;
    test_score_player(test_midi[i]);
    <<< "", "" >>>;
    // score.getScoreDuration() * (1/sp.rate) => now;

}

// ========================== while loop ==========================

while(true)
{
    1::second => now;
}
