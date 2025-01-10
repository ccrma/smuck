@import "ezInstrument.ck"

public class defaultVoice extends ezInstrument
{
    // define sound chain
    20 => n_voices;
    SinOsc oscs[n_voices]; 
    ADSR envs[n_voices]; 
    Gain g => NRev rev => dac;
    g.gain(.1);
    rev.mix(.01);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(4::ms, 7000::ms, 0.0, 200::ms);
    }

    fun void noteOn(int which, ezNote theNote)
    {
        Std.mtof(theNote.pitch) => oscs[which].freq;
        (theNote.velocity / 127.0) => oscs[which].gain;
        envs[which].keyOn();
    }

    fun void noteOff(int which)
    {
        envs[which].keyOff();
    }

    // fun void midiCC(ezCC cc)
    // {
    //     if (cc.type == GAIN)
    //     {

    //     }
    //     //if (cc.type == 10)
    // }
}

