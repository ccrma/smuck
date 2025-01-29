@import "ezInstrument.ck"

@doc "Default ezInstrument that uses a simple signal chain of sine oscillators and envelopes. Used as the instrument for ezScorePlayer's .preview() function. Handles up to 128 simultaneous voices. Signal chain is: SinOsc[128] => ADSR[128] => Gain => NRev => dac. See full class definition at https://github.com/smuck/smuck/blob/main/src/smuck/ezDefaultInst.ck"
public class ezDefaultInst extends ezInstrument
{
    // define sound chain
    @doc "(hidden)"
    128 => int n_voices;

    @doc "Array of sine oscillators"
    SinOsc oscs[n_voices]; 

    @doc "Array of ADSR amplitude envelopes. Envelopes are set to attack = 4ms, decay = 7000ms, sustain = 0.0, release = 200ms by default"
    ADSR envs[n_voices]; 

    @doc "Post-envelope bus for gain control of all voices. Gain set to .1 by default"
    Gain bus;

    @doc "Reverb at end of signal chain. Mix set to .01 by default"
    NRev reverb => dac;

    bus => reverb;
    bus.gain(0.1);
    reverb.mix(.01);

    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => bus;
        envs[i].set(4::ms, 7000::ms, 0.0, 200::ms);
    }

    setVoices(n_voices);

    @doc "this noteOn() function uses theNote.pitch() to set the frequency of the oscillator and theNote.velocity() to set the gain. It also calls .keyOn() on the envelope. The variable 'which' determines which oscillator/envelope to use and is passed in by the ezScorePlayer."
    fun void noteOn(ezNote theNote, int which)
    {
        Std.mtof(theNote.pitch()) => oscs[which].freq;
        (theNote.velocity() / 127.0) => oscs[which].gain;
        envs[which].keyOn();
    }

    @doc "this noteOff() function calls .keyOff() on the envelope. The variable 'which' determines which oscillator/envelope to use and is passed in by the ezScorePlayer."
    fun void noteOff(ezNote theNote, int which)
    {
        envs[which].keyOff();
    }
}

