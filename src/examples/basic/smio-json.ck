//-----------------------------------------------------------------------------
// name: smio-json.ck
// desc: Writing score to JSON and reading score from JSON with smIO: scoreToJson, jsonToScore
// NOTE: smIO depends on the HashMap chugin to be installed. Make sure to chump install HashMap before importing smIO.
// author: Alex Han
//-----------------------------------------------------------------------------
@import {"../../smuck.ck", "../../smuck/smIO.ck"} // NOTE: smIO must be explicitly imported

// Create score with notes
ezPart part("c4 e g c5|h d4 f a4");
ezScore score;
score.add(part);
score.bpm(120);

// Save to JSON (use filepath for headless execution)
me.dir() + "score.json" => string filepath;
smIO.scoreToJson(filepath, score);

// Load from JSON
smIO.jsonToScore(filepath) @=> ezScore loaded;

// Verify: same note count
score.parts()[0].measures()[0].notes().size() => int origNotes;
loaded.parts()[0].measures()[0].notes().size() => int loadedNotes;
<<< "Original notes:", origNotes, "| Loaded notes:", loadedNotes >>>;

// Play back loaded score to confirm
ezDefaultInst inst => dac;
ezScorePlayer player(loaded);
player.instruments([inst]);
player.play();
loaded.duration() => now;
