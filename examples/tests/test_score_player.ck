Hid kb;
HidMsg kb_msg;

// which keyboard
3 => int device;
// get from command line
if( me.args() ) me.arg(0) => Std.atoi => device;

// open keyboard (get device number from command line)
if( !kb.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + kb.name() + "' ready", "" >>>;

// infinite event loop
fun void kb_listener()
{
    while( true )
    {
        // wait on event
        kb => now;

        // get one or more messages
        while( kb.recv( kb_msg ) )
        {
            // check for action type
            if( kb_msg.isButtonDown() )
            {
                <<< "down:", kb_msg.which, "(code)", kb_msg.key, "(usb key)", kb_msg.ascii, "(ascii)" >>>;
                kb_set_playhead(kb_msg.which);
            }
            
            else
            {
                //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            }
        }
    }
}
spork ~ kb_listener();



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Hid trak;
HidMsg trak_msg;

// which keyboard
0 => int trak_device;

// z axis deadzone
0.007 => float DEADZONE;

// open joystick 0, exit on fail
if( !trak.openJoystick( trak_device ) ) me.exit();

// print
<<< "joystick '" + trak.name() + "' ready", "" >>>;

// data structure for gametrak
class GameTrak
{
    // timestamps
    time lastTime;
    time currTime;
    
    // previous axis data
    float lastAxis[6];
    // current axis data
    float axis[6];
}

// gametrack
GameTrak gt;

// spork control
spork ~ gametrak();

// gametrack handling
fun void gametrak()
{
    while( true )
    {
        // wait on HidIn as event
        trak => now;
        
        // messages received
        while( trak.recv( trak_msg ) )
        {
            // <<< "axes:", gt.axis[0],gt.axis[1],gt.axis[2], gt.axis[3],gt.axis[4],gt.axis[5]>>>;
            // joystick axis motion
            if( trak_msg.isAxisMotion() )
            {
                // check which
                if( trak_msg.which >= 0 && trak_msg.which < 6 )
                {
                    // check if fresh
                    if( now > gt.currTime )
                    {
                        // time stamp
                        gt.currTime => gt.lastTime;
                        // set
                        now => gt.currTime;
                    }
                    // save last
                    gt.axis[trak_msg.which] => gt.lastAxis[trak_msg.which];
                    // the z axes map to [0,1], others map to [-1,1]
                    if( trak_msg.which != 2 && trak_msg.which != 5 )
                    { trak_msg.axisPosition => gt.axis[trak_msg.which]; }
                    else
                    {
                        1 - ((trak_msg.axisPosition + 1) / 2) - DEADZONE => gt.axis[trak_msg.which];
                        if( gt.axis[trak_msg.which] < 0 ) 0 => gt.axis[trak_msg.which];
                    }
                }
            }

        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@import {"../../src/smuck.ck"}

ezScore score;
score.setTempo(128);
score.setTimeSig(4, 4);
score.importMIDI("../data/sonata01-1.mid");

ScorePlayer sp(score);

Voice part1;
// part1.init();
// spork~part2();

class Voice
{
    fun Voice()
    {
        spork~noteEventListener();
        // spork~envPrint();
    }

    8 => int n_voices;
    SinOsc oscs[n_voices]; 
    ADSR envs[n_voices]; 
    Gain g => NRev rev => dac;
    g.gain(.8);
    rev.mix(.05);
    for(int i; i < n_voices; i++)
    {
        oscs[i] => envs[i] => g;
        envs[i].set(20::ms, 7000::ms, 0.0, 120::ms);
    }

    fun noteEventListener()
    {
        while(true)
        {
            sp.nextNotes[1] => now;
            sp.nextNotes[1].notes @=> ezNote currentNotes[];
            for(int i; i < currentNotes.size(); i++)
            {   
                spork~playNote(i, currentNotes[i]);
            }
        }
    }

    fun playNote(int which, ezNote theNote)
    {
        Std.mtof(theNote.pitch) => oscs[which].freq;

        sp.playhead/ms => float onset_ms;
        60000 / sp.score.bpm => float ms_per_beat;
        theNote.beats * ms_per_beat => float duration_ms;
        Math.sgn(sp.rate) => float direction;
        duration_ms*direction + onset_ms => float offset_ms;

        while((sp.playhead/ms - onset_ms)*direction < duration_ms)
        {
            envs[which].keyOn();
            sp.tick => now;
        }
        envs[which].keyOff();
    }

    fun flushNotes()
    {
        for(int i; i < n_voices; i++)
        {
            envs[i].keyOff();
            0.0 => envs[i].value;
            cherr <= "voice " <= i <= " envelope value: " <= envs[i].value() <= IO.newline();
            cherr <= "voice " <= i <= " envelope target: " <= envs[i].target() <= IO.newline();
        }
    }

    fun void envPrint()
    {
        while(true)
        {
            for(int i; i < n_voices; i++)
            {
                cherr <= "voice " <= i <= " envelope value: " <= envs[i].value() <= IO.newline();
            }
            10::ms => now;
        }
    }
}

fun void part2()
{
    8 => int n_voices;
    TriOsc osc[n_voices]; 
    ADSR env[n_voices]; 
    Gain g => NRev rev => dac;
    g.gain(.8);
    rev.mix(.05);
    for(int i; i < n_voices; i++)
    {
        osc[i] => env[i] => g;
        osc[i].gain(1.0);
        env[i].set(50::ms, 800::ms, 0.0, 100::ms);
    }

    while(true)
    {
        sp.nextNotes[2] => now;
        //<<< "Playing", sp.nextNotes[2].notes.size(), "note(s) at", sp.playhead >>>;
        sp.nextNotes[2].notes @=> ezNote currentNotes[];
        for(int i; i < currentNotes.size(); i++)
        {
            Std.mtof(currentNotes[i].pitch) => osc[i].freq;
            env[i].keyOn();
        }
    }
}

fun void kb_set_playhead(int which)
{
    if (which == 39) 
    {
        part1.flushNotes();
        for(int i; i < part1.n_voices; i++)
        {
            part1.envs[i].keyOff();
        }
        sp.pos(0.0);
    }
}

fun void changeRate()
{
    while(true)
    {
        gt.axis[3]*1.5 => sp.rate;
        1::second => now;
    }
}

spork~changeRate();

while(true)
{
    1::second => now;
}