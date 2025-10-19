//-----------------------------------------------------------------------------
// name: releaseInst.ck
// desc: This ezInstrument demonstrates how to design instruments with long release
// times that may extend beyond the end of a note's duration.
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

public class releaseInst extends ezInstrument
{
    numVoices(16);
    TriOsc oscs[numVoices()] => ADSR envs[numVoices()] => LPF lpf => outlet;

    2200 => lpf.freq;

    for(int i; i < numVoices(); i++)
    {
        envs[i].set(50::ms, 450::ms, 0.9, 2500::ms); // Set up an ADSR envelope with a 2.5 second release time
    }

    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch()) => oscs[voice].freq;
        envs[voice].keyOn();
    }

    fun void noteOff(ezNote note, int voice)
    {
        envs[voice].keyOff();
        envs[voice].releaseTime() => now; // Allows time to pass after keyOff is called, letting the note release to happen
    }
}