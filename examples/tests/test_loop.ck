@import {"../../src/smuck.ck"}


ezScore score("a4 b c d e");

ezScorePlayer player(score);

player.loop(true);

player.preview();

eon => now;
