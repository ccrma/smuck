//-----------------------------------------------------------------------------
// name: ezcc-basic.ck
// desc: Manual CC creation and playback with ezCC, measure.add(cc), instrument.cc()
// author: Alex Han
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

// Custom instrument that overrides cc() to handle CC events (ezDefaultInst prints to console)
class CCInst extends ezDefaultInst
{
    // Override cc() to modulate gain based on volume CC (CC7)
    fun void cc(ezCC cc)
    {
        if (cc.isCC() && cc.data1() == 7)
        {
            // Volume CC: scale 0-127 to gain
            cc.data2() / 127.0 => float g;
            bus.gain(g * 0.25);
        }
        // Also print for visibility
        <<< "CC: ch=", cc.channel(), " ctrl=", cc.data1(), " val=", cc.data2(), " onset=", cc.onset() >>>;
    }
}

// Build a short score with notes and CCs in the same measure
ezMeasure m("c4 e g c5");
// Add CCs: volume ramp, modulation at beat 2
ezCC.volume(0, 64, 0.0) @=> ezCC volStart;
ezCC.volume(0, 127, 2.0) @=> ezCC volEnd;
ezCC.modulation(0, 64, 1.0) @=> ezCC mod;
m.add([volStart, volEnd, mod]);
ezPart part;
part.add(m);
ezScore score;
score.add(part);

// Use our CC-aware instrument
CCInst inst => dac;
ezScorePlayer player(score);
player.instruments([inst]);

// Play and let run to completion
player.loop(true);
player.play();
eon => now;
