@import "ezNote.ck"
@import "smuckish.ck"

public class ezMeasure
{
    // Private variables
    int _pitches[0][0];
    float _rhythms[0];
    int _velocities[0];

    float _length;
    float _onset;

    // Public variables
    ezNote notes[0];
    
    // Constructors
    fun ezMeasure(string input)
    {
        setInterleaved(input);
    }

    fun ezMeasure(string input, int fill_mode)
    {
        setInterleaved(input, fill_mode);
    }

    // Public functions
    fun void addNote(ezNote note)
    {
        notes << note;
    }

    fun void printNotes()
    {
        chout <= "There are " <= notes.size() <= " notes in this measure:" <= IO.newline();
        for(int i; i < notes.size(); i++)
        {
            chout <= "Note " <= i <= ": ";
            chout <= "onset = " <= notes[i].onset() <= ", ";
            chout <= "beats = " <= notes[i].beats() <= ", ";
            chout <= "pitch = " <= smUtils.mid2str(notes[i].pitch()) <= ", ";
            chout <= "velocity = " <= notes[i].velocity() <= IO.newline();
        }
    }


    // Member variable get/set functions

    // Set the onset of the measure in beats, relative to the start of the score
    fun void onset(float o)
    {
        o => _onset;
    }

    // Get the onset of the measure in beats, relative to the start of the score
    fun float onset()
    {
        return _onset;
    }

    // Set the length of the measure in beats
    fun void length(float l)
    {
        l => _length;
    }

    // Get the length of the measure in beats
    fun float length()
    {
        return _length;
    }

    // SMucKish parsing function

    // Set pitches from a single string
    fun void setPitches(string input)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }
    
    // Set pitches from an array of individual string tokens
    fun void setPitches(string input[])
    {
        smPitch.parse_tokens(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set pitches directly from an a 2D array of ints
    fun void setPitches(int input[][])
    {
        input @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set rhythms from a single string
    fun void setRhythms(string input)
    {
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set rhythms from an array of individual string tokens
    fun void setRhythms(string input[])
    {
        smRhythm.parse_tokens(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set rhythms from an array of floats
    fun void setRhythms(float input[])
    {
        input @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set velocities from a single string
    fun void setVelocities(string input)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set velocities from an array of individual string tokens
    fun void setVelocities(string input[])
    {
        smVelocity.parse_tokens(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set velocities from an array of ints
    fun void setVelocities(int input[])
    {
        input @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set pitches from a string, with fill mode
    fun void setPitches(string input, int fill_mode)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Set rhythms from a string, with fill mode
    fun void setRhythms(string input, int fill_mode)
    {
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Set velocities from a string, with fill mode
    fun void setVelocities(string input, int fill_mode)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Private functions
    fun void setInterleaved(string input)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, 1);
    }

    fun void setInterleaved(string input, int fill_mode)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, fill_mode);
    }

    fun void compile_notes(int new_pitches[][], float new_rhythms[], int new_velocities[], int fill_mode)
    {
        ezNote new_notes[0];

        int temp_pitches[0][0];
        float temp_rhythms[0];
        int temp_velocities[0];

        60 => int current_pitch;
        1.0 => float current_rhythm;
        100 => int current_velocity;
        0.0 => float current_onset;

        Math.max(new_pitches.size(), Math.max(new_rhythms.size(), new_velocities.size())) => int max_length;

        if(max_length == 0)
        {
            <<<"ERROR: No pitches, rhythms, or velocities found in input">>>;
            return;
        }

        for(int i; i < max_length; i++)
        {
            if(new_pitches.size() > i)
            {
                int temp_chord[0];
                for(int j; j < new_pitches[i].size(); j++)
                {
                    ezNote note;

                    if(new_pitches[i][j] > 0)
                    {
                        // Set the pitch
                        note.pitch(new_pitches[i][j]);
                        new_pitches[i][j] => current_pitch;
                        // Set the onset
                        note.onset(current_onset);

                        // If rhythm token present for this index, set the rhythm
                        if(new_rhythms.size() > i)
                        {
                            note.beats(new_rhythms[i]);
                            new_rhythms[i] => current_rhythm;
                        }
                        // otherwise, fill the rhythm
                        else
                        {
                            // If fill mode is 1, fill the rhythm with the last recorded rhythm
                            if(fill_mode == 1)
                            {
                                note.beats(current_rhythm);
                            }
                            // otherwise, fill with default rhythm of 1.0
                            else
                            {
                                note.beats(1.0);
                                1.0 => current_rhythm;
                            }
                        }

                        // If velocity token present for this index, set the velocity
                        if(new_velocities.size() > i)
                        {
                            note.velocity(new_velocities[i]);
                            new_velocities[i] => current_velocity;
                        }
                        // otherwise, fill the velocity
                        else
                        {
                            // If fill mode is 1, fill the velocity with the last recorded velocity
                            if(fill_mode == 1)
                            {
                                note.velocity(current_velocity);
                            }
                            // otherwise, fill with default velocity of 100
                            else
                            {
                                note.velocity(100);
                                100 => current_velocity;
                            }
                        }

                        temp_chord << note.pitch();
                        // Add the note to the list
                        new_notes << note;
                    }
                }

                // Add the parsed elements to the temp arrays
                temp_pitches << temp_chord;
                temp_rhythms << current_rhythm;
                temp_velocities << current_velocity;

                // Increment the onset
                current_rhythm +=> current_onset;
            }
            // If no pitch token present for this index, try to create note using last recorded pitch (or default pitch if none)
            else
            {
                // The new note to be added
                ezNote note;

                // Temporary array to hold the new pitch
                int temp_chord[0];
                temp_chord << current_pitch;

                if(fill_mode == 1)
                {
                    note.pitch(current_pitch);
                }
                else
                {
                    note.pitch(60);
                    60 => current_pitch;
                }
                // Set the onset
                note.onset(current_onset);

                // If rhythm token present for this index, set the rhythm
                if(new_rhythms.size() > i)
                {
                    note.beats(new_rhythms[i]);
                    new_rhythms[i] => current_rhythm;
                }
                // otherwise, fill the rhythm
                else
                {
                    // If fill mode is 1, fill the rhythm with the last recorded rhythm
                    if(fill_mode == 1)
                    {
                        note.beats(current_rhythm);
                    }
                    // otherwise, fill with default rhythm of 1.0
                    else
                    {
                        note.beats(1.0);
                        1.0 => current_rhythm;
                    }
                }

                // If velocity token present for this index, set the velocity
                if(new_velocities.size() > i)
                {
                    note.velocity(new_velocities[i]);
                    new_velocities[i] => current_velocity;
                }
                // otherwise, fill the velocity
                else
                {
                    // If fill mode is 1, fill the velocity with the last recorded velocity
                    if(fill_mode == 1)
                    {
                        note.velocity(current_velocity);
                    }
                    // otherwise, fill with default velocity of 100
                    else
                    {
                        note.velocity(100);
                        100 => current_velocity;
                    }
                }

                // Add the note to the list
                new_notes << note;

                // Add the parsed elements to the temp arrays
                temp_pitches << temp_chord;
                temp_rhythms << current_rhythm;
                temp_velocities << current_velocity;

                // Increment the onset
                current_rhythm +=> current_onset;
            }
        }

        // Copy the new notes to the notes array
        new_notes @=> notes;

        // Copy the temp arrays to the global arrays
        temp_pitches @=> _pitches;
        temp_rhythms @=> _rhythms;
        temp_velocities @=> _velocities;

        notes[-1].onset() + notes[-1].beats() => _length;

    }
}