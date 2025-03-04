@import "Chumpinate"
@import "../src/smuck.ck"

// Our package version
Smuck.version() => string version;

<<< "Generating SMucK package release..." >>>;

// instantiate a Chumpinate package
Package pkg("smuck");

// Add our metadata...
["Alex Han", "Kiran Bhat", "Ge Wang"] => pkg.authors;

"https://chuck.stanford.edu/smuck/" => pkg.homepage;
"https://github.com/ccrma/smuck/" => pkg.repository;

"MIT" => pkg.license;
"A framework for symbolic music notation and playback in ChucK" => pkg.description;

["notation", "symbolic", "smuckish", "music"] => pkg.keywords;

// generate a package-definition.json
// This will be stored in "Smuck/package.json"
"./" => pkg.generatePackageDefinition;

<<< "Defining version " + version >>>;;

// Now we need to define a specific PackageVersion for test-pkg
PackageVersion ver("smuck", version);

"1.5.4.5" => ver.languageVersionMin; // what version?

"any" => ver.os;
"all" => ver.arch;

// all the files
ver.addFile("../src/smuck.ck");
ver.addFile("../src/smuck/Smuckish.ck", "smuck");
ver.addFile("../src/smuck/ezPart.ck", "smuck");
ver.addFile("../src/smuck/ezDefaultInst.ck", "smuck");
ver.addFile("../src/smuck/ezScore.ck", "smuck");
ver.addFile("../src/smuck/ezExternalInst.ck", "smuck");
ver.addFile("../src/smuck/ezScorePlayer.ck", "smuck");
ver.addFile("../src/smuck/ezFluidInst.ck", "smuck");
ver.addFile("../src/smuck/smChord.ck", "smuck");
ver.addFile("../src/smuck/ezInstrument.ck", "smuck");
ver.addFile("../src/smuck/smPitch.ck", "smuck");
ver.addFile("../src/smuck/ezMeasure.ck", "smuck");
ver.addFile("../src/smuck/smRhythm.ck", "smuck");
ver.addFile("../src/smuck/ezMidiInst.ck", "smuck");
ver.addFile("../src/smuck/smScale.ck", "smuck");
ver.addFile("../src/smuck/ezNote.ck", "smuck");
ver.addFile("../src/smuck/smScore.ck", "smuck");
ver.addFile("../src/smuck/smUtils.ck", "smuck");
ver.addFile("../src/smuck/ezOscInst.ck", "smuck");
ver.addFile("../src/smuck/smVelocity.ck", "smuck");

// "SMuck/_examples"

// // These build files are examples as well
// ver.addExampleFile("build-pkg-win.ck");
// ver.addExampleFile("build-pkg-mac.ck");
// ver.addExampleFile("build-pkg-linux.ck");

// // Documentation files
// ver.addDocsFile("./index.html");
// ver.addDocsFile("./chumpinate.html");
// ver.addDocsFile("./ckdoc.css");

"smuck/files/" + ver.version() + "/smuck.zip" => string path; // path?

// wrap up all our files into a zip file, and tell Chumpinate what URL
// this zip file will be located at.
ver.generateVersion("./", "smuck", "https://chuck.stanford.edu/release/chump/" + path);

chout <= "Use the following commands to upload the package to CCRMA's servers:" <= IO.newline();
chout <= "ssh alexhan@ccrma-gate.stanford.edu \"mkdir -p ~/Library/Web/smuck/"
      <= ver.version() <= "/\"" <= IO.newline();
chout <= "scp smuck.zip alexhan@ccrma-gate.stanford.edu:~/Library/Web/" <= path <= IO.newline();

// Generate a version definition json file, stores this in "chumpinate/<VerNo>/Smuck.json"
ver.generateVersionDefinition("smuck", "./" );