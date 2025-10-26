//-----------------------------------------------------------------------------
// name: piano-phase.ck
// desc: a smuck implemetation of the first half of Steve Reich's Piano Phase.
//       The original has two pianos playing the same 12-note phrase. One
//       player begins accelerating slightly so that after several reptitions
//       the faster player will end up one note ahead of the other player. The
//       first half of piano phase goes through 12 sets of phasing so that the
//       pianos return to playing in unison.
//
// author: Nick Shaheed (nshaheed@ccrma.stanford.edu)
//-----------------------------------------------------------------------------

@import "../smuck.ck"

// Set up our signal chain
basicInst inst_base => JCRev jl =>dac.left;
basicInst inst_phase => Envelope env => JCRev jr => dac.right;

0.1 => jl.mix => jr.mix;

// The 12-note sequence Piano Phase is based around
"e|s fs b cs d fsd e csu b fs du cs" => string notes;
ezScore cell_base(notes);
ezScore cell_phase(notes);

// The score says 72, but I like it faster
85 => float tempo;
tempo => cell_base.bpm;
tempo => cell_phase.bpm;

// create two score players
ezScorePlayer player_base(cell_base);
ezScorePlayer player_phase(cell_phase);

// of course we're looping
true => player_base.loop => player_phase.loop;

// because of the precise timing needed with the phasing, we need
// ScorePlayer's tick to be sample-accurate
samp => player_base.tick => player_phase.tick;

inst_base => player_base.instruments;
inst_phase => player_phase.instruments;

// intro
player_base.play();
player_phase.play();

// how long our loop is in beats
cell_base.duration() => dur len;

// The first measure, only the first piano is heard
Math.random2(4,8)::len => now;

// 2nd player introduced
chout <= "player 2 comes in..." <= IO.newline();
Math.random2(12,18) => int repeats;
env.ramp(repeats::len, 1.) => now;

// Begin the phasing process
for(int i: Std.range(12)) {
    run_phase(Math.random2(4,16));
    // after every phase, let the new combination of notes sit for a while
    Math.random2(12,24)::len => now;
}

// Begin the outro of section 1
Math.random2(4,8) => repeats;
env.ramp(repeats::len, 0.) => now;

// Base piano solo and then we end
Math.random2(4,8)::len => now;

player_base.stop();
player_phase.stop();

5::second => now; // let the reverb die out

// Create instrument(s) for playback
class basicInst extends ezInstrument
{
    // How many voices our instrument has (for polyphony)
    10 => int n_voices;
    numVoices(n_voices); 
    Blit oscs[n_voices] => ADSR adsrs[n_voices];
    Impulse imp[n_voices];
    Gain g => outlet;
    g.gain(0.1);
    for (0 => int i; i < n_voices; i++)
    {
	4 => oscs[i].harmonics;
	Math.randomf() => oscs[i].phase; // Randomize the phase to add some variety to attacks
        oscs[i].gain(0);          // We want each osc to be silent before a note is played
        adsrs[i] => g;
	imp[i] => g;

	adsrs[i].set( 10::ms, 8::ms, .5, 100::ms );
    }
    
    // Implement required noteOn and noteOff functions
    //--------------------------------
    fun void noteOn(ezNote note, int voice) // noteOn and noteOff must have these arguments!
    {
        Std.mtof(note.pitch()) => oscs[voice].freq; // pitches are MIDI note numbers (e.g. 60 is middle C)
        note.velocity() => oscs[voice].gain; // ezNote velocities are float values 0.0-1.0
	adsrs[voice].keyOn();
	1.0 => imp[voice].next;
    }

    // What our instrument does when a note is released (this function is called automatically by the score player)
    fun void noteOff(ezNote note,int voice)
    {
        // 0 => oscs[voice].gain;
	adsrs[voice].keyOff();
    }
}



fun run_phase(int repetitions) {
    // Here we do the actual phasing logic
    chout <= "begin phasing over " <= repetitions <= " bars" <= IO.newline();
    cell_base.beats() * repetitions => float num_beats;

   /*
    *
    *  The phasing player needs to accelerate so that when the given
    *  number of repetitions of the measure have passed it is one
    *  sixteenth note further ahead of the base player compared to
    *  where it was before the phasing sequence began. i.e. if the
    *  phase player's position is the same as the base player, by
    *  the end of the phasing sequence the phase player will be 0.25
    *  beats ahead of the base player.
    *
    *  So, over the num_beats of the phase sequence, the phase
    *  player should be *just* slightly faster. This change in BPM
    *  can be calculated with this formula:
    *
    *                                  1        
    *  proportion(numbeats) = ──────────────────
    *                             ⎛      1     ⎞
    *                         1 - ⎜────────────⎟
    *                             ⎝numbeats ⋅ 8⎠
    *
    *  Don't ask me how I came up with this, it's gone from my brain
    *
    */
    1. / (1. - (1. / (num_beats * 8))) => float proportion;

    tempo * proportion => player_phase.bpm;

    // Because of numerical error the final position won't be perfect, we want to
    // properly align the phase player's position a sample before the note attack
    // so that it won't be skipped
    num_beats * (minute/tempo) - samp => now;
    
    // Round to the nearest 0.25 beat and modulo it to stay within bounds
    (Math.round(player_phase.pos() * 4.) / 4.) % player_phase.endPos() => player_phase.pos;
    samp => now; // sync up

    tempo => player_phase.bpm;
    chout <= "ending phasing" <= IO.newline();
}