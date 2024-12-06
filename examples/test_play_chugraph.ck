Hid kb;
HidMsg kb_msg;

// which keyboard
0 => int device;
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
                // <<< "down:", kb_msg.which, "(code)", kb_msg.key, "(usb key)", kb_msg.ascii, "(ascii)" >>>;
                kb_set_playhead(kb_msg.which);
                kb_set_rate(kb_msg.which);
            }
            
            else
            {
                //<<< "up:", msg.which, "(code)", msg.key, "(usb key)", msg.ascii, "(ascii)" >>>;
            }
        }
    }
}
spork ~ kb_listener();

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@import {"../src/smuck.ck"}

ezScore score("data/sonata01-1.mid", 128, [4,4]);

ScorePlayer sp(score);

MyVoice v1;
MyVoice v2;
sp.setVoice(0, v1);     // set voice for part 1 to v1
sp.setVoice(1, v2);


fun void kb_set_playhead(int which)
{
    if (which == 39) 
    {
        <<<"0 pressed">>>;
        sp.pos(15, 1.5);
    }
}

fun void kb_set_rate(int which)
{
    if(which == 29)
    {
        .1 -=> sp.rate;
        <<<"rate:", sp.rate>>>;
    }
    if(which == 27)
    {
        .1 +=> sp.rate;
        <<<"rate:", sp.rate>>>;
    }  
}

while(true)
{
    1::second => now;
}