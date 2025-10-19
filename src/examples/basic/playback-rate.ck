//-----------------------------------------------------------------------------
// name: playback.ck
// desc: this example shows how to control playback of a score
//
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/)
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

// Load a score from MIDI file
ezScore score(me.dir() + "../data/bwv772.mid");

// Create a score player
ezScorePlayer player(score);

// Set some playback options
player.loop(true);
player.preview();

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
