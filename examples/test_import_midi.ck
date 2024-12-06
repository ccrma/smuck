@import {"../src/smuck.ck"}
ezScore score;
score.importMIDI("data/bwv772.mid");
<<< score.parts.size() >>>;
<<< score.parts[0].measures.size() >>>;
<<< score.parts[1].measures[0].notes.size() >>>;

for (int n; n < 10; n++) {
    <<< score.parts[1].measures[0].notes[n].pitch >>>;
    <<< score.parts[1].measures[0].notes[n].onset >>>;
    <<< score.parts[1].measures[0].notes[n].beats >>>;
}


// <<< score.parts[0].measures[0].notes.size() >>>;
