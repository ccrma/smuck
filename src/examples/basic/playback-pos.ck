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

// Set the playback position with a number of beats (float)
player.startPos(32.0);
player.endPos(40.0); 

// Let the score play for 10 seconds
10::second => now;

// Set the playback start and end positions using time (dur)
player.startPos(5::second); 
player.endPos(8::second); 

// Let the score play for 10 seconds
10::second => now;

// Reset the playback start and end positions
player.startPos(0.0);
player.endPos(score.beats());

// Move the playback position to a specific beat position
player.pos(16.0);

// Let the score play for 5 seconds
5::second => now;

// Move the playback position to a specific time position
player.pos(10::second);

// Let the score play for 5 seconds
5::second => now;