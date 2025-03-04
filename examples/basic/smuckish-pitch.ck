//-----------------------------------------------------------------------------
// name: smuckish-pitch.ck
// desc: this example shows how various SMucKish pitch input strings are parsed
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------
@import "smuck"

string inputs[0];

// Accidentals
inputs << "a b c d e";     // 0 
inputs << "af bf c df ef"; // 1
inputs << "ab bb c db eb"; // 2
inputs << "as b cs d e";   // 3
inputs << "a# b c# d e";   // 4

inputs << "k4f a b c d e";                // 5
inputs << "k4f an bn c# dn en";           // 6
inputs << "a bff c dffffffffffffffffff";  // 7

// Octaves
inputs << "a5 b3 c7 d2 e8";              // 8
inputs << "a3 b c d e";                  // 9
inputs << "a3 b cd d e";                 // 10
inputs << "a3 b cddd d e";               // 11

// Chords
inputs << "a:c:e";                       // 12
inputs << "a:cd:e";                      // 13
inputs << "a3:c:e:g a3:c:e:g";           // 14

// Repeats
inputs << "ax3 c d";                      // 15
inputs << "[a b c]x3 d e";                // 16
inputs << "a3:c:e:gx2";                   // 17

// Rests
inputs << "a r b c d";                    // 18

// Putting it all together
inputs << "k3f a3:c:e:gx2 [a b cs]x3 du euu"; // 19

// Set which string you want to test
0 => int index; 

Smuckish.pitches(inputs[index]) @=> float pitches[][];

for(int i; i < pitches.size(); i++)
{
    for(int j; j < pitches[i].size(); j++)
    {
        <<<"pitch: ", smUtils.mid2str(pitches[i][j] $ int)>>>;
    }
}