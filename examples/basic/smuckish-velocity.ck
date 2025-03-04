//-----------------------------------------------------------------------------
// name: smuckish-velocity.ck
// desc: this example shows how various SMucKish velocity input strings are parsed
//
// author: Alex Han (https://ccrma.stanford.edu/~alexhan/)
//-----------------------------------------------------------------------------
@import "smuck"

string inputs[0];

//Values outside range (0.0 - 1.0) will be clamped
inputs << "0 -10 47 80 111 132";                 //0
// Dynamic markings are mapped to 0.0-1.0      
inputs << "pppp ppp pp p mp mf f ff fff ffff";   //1
// When using interleaved input, use prefix 'v' to disambiguate velocity from rhythm values
inputs << "v0.0 v.80 v.7 v.12 v.98";             //2

// Set which string you want to test
0 => int index;

Smuckish.velocities(inputs[index]) @=> float velocities[]; 

for(int i; i < velocities.size(); i++)
{
    <<<"velocity: ", velocities[i]>>>;
}