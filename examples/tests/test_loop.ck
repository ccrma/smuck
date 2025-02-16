@import {"../../src/smuck.ck"}


ezScore score("a4 b c d e");

ezScorePlayer player(score);

player.loop(true);

player.preview();


10::second => now;

player.rate(-1.0);

10::second => now;

player.rate(1.0);

10::second => now;


