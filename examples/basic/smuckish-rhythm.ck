//-----------------------------------------------------------------------------
// name: smuckish-rhythm.ck
// desc: this example shows how various SMucKish rhythm input strings are parsed
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------

@import "smuck"

string inputs[0];

// Basic rhythms
inputs << "s e q h w";                    // 0

// Dotted rhythms
inputs << "q. q.. q... q....";            // 1

// Tuplets
inputs << "tq tq tq";                     // 2
inputs << "q/3 q/3 q/3";                  // 3
inputs << "q/7 q/13 q/19";                // 4

// Weird combos
inputs << "tq.";                          // 5

// Arbitrary beat values
inputs << "1.0 1.7 3.6";                  // 6

// Repeats
inputs << "ex16";                         // 7
inputs << "[q q te te te]x4";             // 8

// Ties
inputs << "e _e _e _e";                   // 9

// Putting it all together
inputs << "[ex3 q.]x2 tq tq q/5 q/5 1.6"; // 10

inputs << "q q. q.. te te te q/5 q/7 h/19 1.7 3.14"; // 11

// Set which string you want to test
0 => int index;

Smuckish.rhythms(inputs[index]) @=> float rhythms[];

for(int i; i < rhythms.size(); i++)
{
    <<<"rhythm: ", rhythms[i]>>>;
}
