@import {"../../src/smuck.ck"}

ezScore score("../data/sonata01-1.mid");
score.bpm(128);
ezScorePlayer sp(score);

sp.tick(2::ms);
-2.0 => sp.rate;
sp.pos(20::second);
1 => sp.loop;
sp.preview();

while(true)
{
    1::second => now;
}