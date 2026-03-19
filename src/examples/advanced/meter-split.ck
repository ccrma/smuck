//-----------------------------------------------------------------------------
// name: meter-split.ck
// desc: All meter() overloads: fixed beat length, list of lengths, time-sig string/array
// author: Alex Han
//-----------------------------------------------------------------------------
@import "../../smuck.ck"

// Build a long measure (12 beats) to demonstrate splitting
ezMeasure m;
ezNote n1(0.0, 4.0, 60, 0.8);
ezNote n2(4.0, 4.0, 64, 0.7);
ezNote n3(8.0, 4.0, 67, 0.9);
m.add(n1);
m.add(n2);
m.add(n3);

ezPart part;
part.add(m);
ezScore score;
score.add(part);

chout <= "Original: 1 measure, 12 beats" <= IO.newline();

// 1. Fixed beat length: meter(float barLength)
part.copy() @=> ezPart p1;
p1.meter(4.0);
chout <= "meter(4.0): " <= p1.measures().size() <= " measures" <= IO.newline();

// 2. List of bar lengths: meter(float lengths[])
part.copy() @=> ezPart p2;
[4.0, 3.0, 4.0] @=> float lengths[];
p2.meter(lengths);
chout <= "meter([4,3,4]): " <= p2.measures().size() <= " measures" <= IO.newline();

// 3. Time signature string: meter(string sig)
part.copy() @=> ezPart p3;
p3.meter("3/4");
chout <= "meter(\"3/4\"): " <= p3.measures().size() <= " measures" <= IO.newline();

// 4. Time signature num/denom: meter(float num, float denom)
part.copy() @=> ezPart p4;
p4.meter(12.0, 8.0);  // 12/8 = 6 beats per bar
chout <= "meter(12, 8): " <= p4.measures().size() <= " measures" <= IO.newline();

// 5. Variable time signatures (strings): meter(string sigs[])
ezMeasure m2;
ezNote n4(0.0, 11.0, 60, 0.8);
m2.add(n4);
ezPart part2;
part2.add(m2);
["4/4", "3/4", "4/4"] @=> string sigs[];
part2.meter(sigs);
chout <= "meter([\"4/4\",\"3/4\",\"4/4\"]): " <= part2.measures().size() <= " measures" <= IO.newline();

// 6. score.meter() applies to all parts
ezScore score2;
score2.add(part.copy());
score2.meter("4/4");
chout <= "score.meter(\"4/4\"): " <= score2.parts()[0].measures().size() <= " measures" <= IO.newline();

// Play one of the split versions
ezDefaultInst inst => dac;
ezScorePlayer player(score2);
player.instruments([inst]);
player.play();
score2.duration() => now;
