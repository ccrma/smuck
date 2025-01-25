@import {"../../src/smuck.ck"}

ezScore score("../data/sonata01-1.mid");
score.setTempo(128);
ezScorePlayer sp(score);

1::ms => sp.tick;
1.0 => sp.rate;
// sp.pos(20::second);
1 => sp.loop;
sp.preview();

while(true)
{
    1::second => now;
}