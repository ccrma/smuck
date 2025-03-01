@import "ezInstrument.ck"

@doc "Default ezInstrument that uses a simple signal chain of sine oscillators and envelopes. Used as the instrument for ezScorePlayer's .preview() function. Handles up to 10 simultaneous voices for a given part. Signal chain is: SinOsc[10] => ADSR[10] => Gain => NRev => dac."
public class ezDefaultInst extends ezInstrument
{
    // define sound chain
    @doc "(hidden)"
    10 => int n_voices;

    @doc "Array of triangle oscillators"
    TriOsc oscs[n_voices]; 

    @doc "Array of ADSR amplitude envelopes. Envelopes are set to attack = 4ms, decay = 7000ms, sustain = 0.0, release = 200ms by default"
    ADSR envs[n_voices]; 

    @doc "Post-envelope bus for gain control of all voices. Gain set to .1 by default"
    Gain bus;
    bus.gain(0.1);
    bus => outlet;
    
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => bus;
        envs[i].set(5::ms, 5000::ms, 0.0, 100::ms);
    }

    setVoices(n_voices);

    @doc "this noteOn() function uses note.pitch() to set the frequency of the oscillator and note.velocity() to set the gain. It also calls .keyOn() on the envelope. The variable 'voice' determines which oscillator/envelope to use and is passed in by the ezScorePlayer."
    fun void noteOn(ezNote note, int voice)
    {
        Std.mtof(note.pitch()) => oscs[voice].freq;
        (note.velocity() / 127.0) => oscs[voice].gain;
        envs[voice].keyOn();
    }

    @doc "this noteOff() function calls .keyOff() on the envelope. The variable 'voice' determines which oscillator/envelope to use and is passed in by the ezScorePlayer."
    fun void noteOff(ezNote note, int voice)
    {
        envs[voice].keyOff();
    }
}

