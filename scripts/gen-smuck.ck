@import "../src/smuck.ck"
// NOTE: requires FluidSynth.chug to be installed
@import "../src/smuck/ezFluidInst.ck"

// instantiate a CKDoc object
CKDoc doc; // documentation orchestra
// set the examples root
// "../examples/" => doc.examplesRoot;

// add group
doc.addGroup(
    // class names
    [
        "ezNote",
        "ezMeasure",
        "ezPart",
        "ezScore"
    ],
    // group name
    "Basic Classes",
    // file name
    "smuck-basic", 
    // group description
    "Basic data structures for holding symbolic music information."
);

// add group
doc.addGroup(
    // class names
    [
        "ezScorePlayer",
        "ezInstrument",
        "ezDefaultInst",
        "ezMidiInst",
        "ezOscInst",
        "ezExternalInst",
        "ezFluidInst" // NOTE: requires FluidSynth.chug to be installed
    ],
    // group name
    "Playback",
    // file name
    "smuck-playback", 
    // group description
    "Objects used to play back ezScore score data."
);

// add group
doc.addGroup(
    // class names
    [
        "Smuck"
        // "Smuckish"
    ],
    // group name
    "Utilities",
    // file name
    "smuck-utils", 
    // group description
    "SMucK-related tools, including utilities for converting SMucKish symbolic notation into ChucK data structures."
);


// sort for now until order is preserved by CKDoc
doc.sort(true);

// generate
doc.outputToDir( ".", "SMucK API Reference (Alpha 0.1.2)" );

// BUG: class doc not showing up
// ezNote.help();
