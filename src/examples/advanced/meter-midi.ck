//-----------------------------------------------------------------------------
// name: meter-midi.ck
// desc: Import MIDI file and call meter(4) to split long measures for better performance
// By default, SMucK will import a MIDI file as a single measure. This example shows how to split long measures into 4-beat bars. 
// This can help improve playback performance for large MIDI files.
// author: Alex Han
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

// Path to MIDI file
me.dir() + "/../../data/bwv772.mid" => string midiPath;

ezScore score;
score.read(midiPath);

chout <= "After import: " <= score.parts()[0].measures().size() <= " measure(s) in part 0" <= IO.newline();

// Split long measures into 4-beat bars; improves playback performance for large MIDI files
score.meter(4.0);

chout <= "After meter(4): " <= score.parts()[0].measures().size() <= " measure(s) in part 0" <= IO.newline();

// Play back
ezDefaultInst inst => dac;
ezScorePlayer player(score);
player.instruments([inst]);
player.play();
score.duration() => now;
