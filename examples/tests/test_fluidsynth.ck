@import {"../../src/smuck.ck"}

ezScore score("../data/demo.mid");
score.bpm(128);
ezScorePlayer sp(score);

Gain g => Dyno dyno => NRev rev => dac;
dyno.compress();
rev.mix(0.05);
ezFluidInst inst0("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst1("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst2("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst3("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst4("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst5("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst6("../data/SalC5Light2.sf2", 0) => g;
ezFluidInst inst7("../data/SalC5Light2.sf2", 0) => g;

sp.setInstrument([inst0, inst1,inst2, inst3, inst4, inst5, inst6, inst7]);

sp.tick(2::ms);
// -2.0 => sp.rate;
// sp.pos(20::second);
1 => sp.loop;
// sp.preview();
sp.play();

while(true)
{
    1::second => now;
}