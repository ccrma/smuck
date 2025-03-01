@import "ezNote.ck"
@import "Smuckish.ck" // for recursive imports

@doc "SMucK measure object. An ezMeasure object contains one or more ezNotes. Note contents can be set using the SMucKish input syntax."
public class ezMeasure
{
    // Private variables
    @doc "(hidden)"
    float _pitches[0][0];
    @doc "(hidden)"
    float _rhythms[0];
    @doc "(hidden)"
    float _velocities[0];

    @doc "(hidden)"
    float _length;
    @doc "(hidden)"
    float _onset;

    // Public variables
    @doc "The ezNote objects in the measure"
    ezNote notes[0];
    
    // Constructors

    @doc "Default constructor, creates an empty measure"
    fun ezMeasure()
    {

    }

    @doc "Create an ezMeasure from a SMucKish input string"
    fun ezMeasure(string input)
    {
        setInterleaved(input);
    }

    //"Create an ezMeasure from a SMucKish input string, with fill mode"
    @doc "(hidden)" 
    fun ezMeasure(string input, int fill_mode)
    {
        setInterleaved(input, fill_mode);
    }

    // Public functions
    @doc "Add an ezNote to the measure"
    fun void addNote(ezNote note)
    {
        notes << note;
    }

    @doc "Print the parameters for each note in the measure"
    fun void printNotes()
    {
        chout <= "There are " <= notes.size() <= " notes in this measure:" <= IO.newline();
        for(int i; i < notes.size(); i++)
        {
            chout <= "Note " <= i <= ": ";
            chout <= "onset = " <= notes[i].onset() <= ", ";
            chout <= "beats = " <= notes[i].beats() <= ", ";
            chout <= "pitch = " <= smUtils.mid2str(notes[i].pitch() $ int) <= ", ";
            chout <= "velocity = " <= notes[i].velocity() <= IO.newline();
        }
    }


    // Member variable get/set functions

    @doc "Set the onset of the measure in beats, relative to the start of the score"
    fun void onset(float value)
    {
        value => _onset;
    }

    @doc "Get the onset of the measure in beats, relative to the start of the score"
    fun float onset()
    {
        return _onset;
    }

    @doc "Set the length of the measure in beats"
    fun void length(float value)
    {
        value => _length;
    }

    @doc "Get the length of the measure in beats"
    fun float length()
    {
        return _length;
    }

    // SMucKish parsing functions

    @doc "Set the pitches of the notes in the measure, using a SMucKish input string"
    fun void setPitches(string input)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }
    
    @doc "Set the pitches of the notes in the measure, using an array of SMucKish string tokens"
    fun void setPitches(string input[])
    {
        smPitch.parse_tokens(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the pitches of the notes in the measure directly from a 2D array of MIDI note numbers"
    fun void setPitches(float input[][])
    {
        input @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the rhythms of the notes in the measure, using a SMucKish input string"
    fun void setRhythms(string input)
    {
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the rhythms of the notes in the measure, using an array of SMucKish string tokens"
    fun void setRhythms(string input[])
    {
        smRhythm.parse_tokens(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the rhythms of the notes in the measure directly from an array of floats"
    fun void setRhythms(float input[])
    {
        input @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the velocities of the notes in the measure, using a SMucKish input string"
    fun void setVelocities(string input)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the velocities of the notes in the measure, using an array of SMucKish string tokens"
    fun void setVelocities(string input[])
    {
        smVelocity.parse_tokens(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    @doc "Set the velocities of the notes in the measure directly from an array of floats"
    fun void setVelocities(float input[])
    {
        input @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);
    }

    // Set pitches from a string, with fill mode
    @doc "(hidden)"
    fun void setPitches(string input, int fill_mode)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Set rhythms from a string, with fill mode
    @doc "(hidden)"
    fun void setRhythms(string input, int fill_mode)
    {
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Set velocities from a string, with fill mode
    @doc "(hidden)"
    fun void setVelocities(string input, int fill_mode)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);
    }

    // Private functions
    @doc "(hidden)"
    fun void setInterleaved(string input)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, 1);
    }

    @doc "(hidden)"
    fun void setInterleaved(string input, int fill_mode)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, fill_mode);
    }

    @doc "(hidden)"
    fun void compile_notes(float new_pitches[][], float new_rhythms[], float new_velocities[], int fill_mode)
    {
        ezNote new_notes[0];

        float temp_pitches[0][0];
        float temp_rhythms[0];
        float temp_velocities[0];

        60 => float current_pitch;
        1.0 => float current_rhythm;
        1.0 => float current_velocity;
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
                // No pitch token present for this index, so it's a rest. If rhythm token present, set the current rhythm so rest has appropriate duration
                if(new_pitches[i].size() == 0 && new_rhythms.size() > i)
                {
                    // <<<"Rest token present for this index", i>>>;
                    new_rhythms[i] => current_rhythm;
                }

                float temp_chord[0];
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
                            // otherwise, fill with default velocity of 1.0
                            else
                            {
                                note.velocity(1.0);
                                1.0 => current_velocity;
                            }
                        }

                        temp_chord << note.pitch();
                        // Add the note to the list
                        new_notes << note;
                    }
                    else // the pitch is less than 0, so it's a rest
                    {
                        if(new_rhythms.size() > i)
                        {
                            new_rhythms[i] => current_rhythm;
                        }
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
                float temp_chord[0];
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
                    // otherwise, fill with default velocity of 1.0
                    else
                    {
                        note.velocity(1.0);
                        1.0 => current_velocity;
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