//-----------------------------------------------------------------------------
// name: simple.ck
// desc: the simplest possible SMucK program with score creation and playback
// author: Kiran Bhat (https://ccrma.stanford.edu/~kvbhat/)
//-----------------------------------------------------------------------------
@import "smuck"

// create simple score
ezScore score("a b c d e f g a");

// create a score player
ezScorePlayer player(score);

// preview the score (play score with preview instrument)
player.preview();
5::second => now;