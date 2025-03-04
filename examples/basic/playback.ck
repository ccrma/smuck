//-----------------------------------------------------------------------------
// name: playback.ck
// desc: this example shows how to control playback of a score
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/)
//-----------------------------------------------------------------------------
@import "/Users/alexhan/Desktop/ChucK/smuck/src/smuck.ck"

ezScore score(me.dir() + "../data/bwv772.mid"); // Load a score from MIDI file

ezScorePlayer player(score);
//player.logPlayback(true); // Uncomment this line to log playback events to console
player.loop(true); // Enable looping of the score
player.preview(); // Play the score with the default "preview" instrument

// Let the score play for 5 seconds
<<<"Playing score...">>>;
5::second => now;

// Set the playback position with a time (dur)
repeat(3)
{
    <<<"Setting playback position to 10 seconds">>>;
    player.pos(10::second); 
    2::second => now;
}

// Set the playback position with a number of beats (float)
repeat(3)
{
    <<<"Setting playback position to 60.5 beats">>>;
    player.pos(60.5);
    2::second => now;
}

// Set the playback rate using a bpm (default is 120)
player.bpm(60);
<<<"BPM set to", player.bpm()>>>;
5::second => now;

// Dynamically adjust the rate of playback
repeat(20)
{
    <<<"Rate set to", player.rate()>>>;
    player.rate() + 0.2 => player.rate;
    200::ms => now;
}

// Pause the player
player.pause();
<<<"Player paused">>>;
3::second => now;

// Reverse playback and resume
-2 => player.rate;
<<<"Rate set to", player.rate()>>>;
player.play();
10::second => now;

// Stop the player
player.stop();
<<<"Player stopped">>>;
3::second => now;
