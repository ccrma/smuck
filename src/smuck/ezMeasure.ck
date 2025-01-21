@import "ezNote.ck"
@import "smuckish.ck"

public class ezMeasure
{
    int pitches[0][0];
    float rhythms[0];
    int velocities[0];

    ezNote notes[0];
    float length;
    float onset;

    fun ezMeasure(string input)
    {
        set_interleaved(input);
    }

    fun ezMeasure(string input, int fill_mode)
    {
        set_interleaved(input, fill_mode);
    }

    fun void add_note(ezNote note)
    {
        notes << note;
    }

    fun void set_pitches(string input)
    {
        smPitch.parse_pitches(input) @=> pitches;
        compile_notes(pitches, rhythms, velocities, 1);
    }

    fun void set_rhythms(string input)
    {
        smRhythm.parse_rhythms(input) @=> rhythms;
        compile_notes(pitches, rhythms, velocities, 1);
    }

    fun void set_velocities(string input)
    {
        smVelocity.parse_velocities(input) @=> velocities;
        compile_notes(pitches, rhythms, velocities, 1);
    }

    fun void set_interleaved(string input)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, 1);
    }

    fun void set_pitches(string input, int fill_mode)
    {
        smPitch.parse_pitches(input) @=> pitches;
        compile_notes(pitches, rhythms, velocities, fill_mode);
    }

    fun void set_rhythms(string input, int fill_mode)
    {
        smRhythm.parse_rhythms(input) @=> rhythms;
        compile_notes(pitches, rhythms, velocities, fill_mode);
    }

    fun void set_velocities(string input, int fill_mode)
    {
        smVelocity.parse_velocities(input) @=> velocities;
        compile_notes(pitches, rhythms, velocities, fill_mode);
    }

    fun void set_interleaved(string input, int fill_mode)
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
                        note.set_pitch(new_pitches[i][j]);
                        new_pitches[i][j] => current_pitch;
                        // Set the onset
                        note.set_onset(current_onset);

                        // If rhythm token present for this index, set the rhythm
                        if(new_rhythms.size() > i)
                        {
                            note.set_beats(new_rhythms[i]);
                            new_rhythms[i] => current_rhythm;
                        }
                        // otherwise, fill the rhythm
                        else
                        {
                            // If fill mode is 1, fill the rhythm with the last recorded rhythm
                            if(fill_mode == 1)
                            {
                                note.set_beats(current_rhythm);
                            }
                            // otherwise, fill with default rhythm of 1.0
                            else
                            {
                                note.set_beats(1.0);
                                1.0 => current_rhythm;
                            }
                        }

                        // If velocity token present for this index, set the velocity
                        if(new_velocities.size() > i)
                        {
                            note.set_velocity(new_velocities[i]);
                            new_velocities[i] => current_velocity;
                        }
                        // otherwise, fill the velocity
                        else
                        {
                            // If fill mode is 1, fill the velocity with the last recorded velocity
                            if(fill_mode == 1)
                            {
                                note.set_velocity(current_velocity);
                            }
                            // otherwise, fill with default velocity of 100
                            else
                            {
                                note.set_velocity(100);
                                100 => current_velocity;
                            }
                        }

                        temp_chord << note.pitch;
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
                    note.set_pitch(current_pitch);
                }
                else
                {
                    note.set_pitch(60);
                    60 => current_pitch;
                }
                // Set the onset
                note.set_onset(current_onset);

                // If rhythm token present for this index, set the rhythm
                if(new_rhythms.size() > i)
                {
                    note.set_beats(new_rhythms[i]);
                    new_rhythms[i] => current_rhythm;
                }
                // otherwise, fill the rhythm
                else
                {
                    // If fill mode is 1, fill the rhythm with the last recorded rhythm
                    if(fill_mode == 1)
                    {
                        note.set_beats(current_rhythm);
                    }
                    // otherwise, fill with default rhythm of 1.0
                    else
                    {
                        note.set_beats(1.0);
                        1.0 => current_rhythm;
                    }
                }

                // If velocity token present for this index, set the velocity
                if(new_velocities.size() > i)
                {
                    note.set_velocity(new_velocities[i]);
                    new_velocities[i] => current_velocity;
                }
                // otherwise, fill the velocity
                else
                {
                    // If fill mode is 1, fill the velocity with the last recorded velocity
                    if(fill_mode == 1)
                    {
                        note.set_velocity(current_velocity);
                    }
                    // otherwise, fill with default velocity of 100
                    else
                    {
                        note.set_velocity(100);
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
        temp_pitches @=> pitches;
        temp_rhythms @=> rhythms;
        temp_velocities @=> velocities;

        notes[-1].onset + notes[-1].beats => length;

    }

    fun void print_notes()
    {
        chout <= "There are " <= notes.size() <= " notes in this measure:" <= IO.newline();
        for(int i; i < notes.size(); i++)
        {
            chout <= "Note " <= i <= ": ";
            chout <= "onset = " <= notes[i].onset <= ", ";
            chout <= "beats = " <= notes[i].beats <= ", ";
            chout <= "pitch = " <= smUtils.mid2str(notes[i].pitch) <= ", ";
            chout <= "velocity = " <= notes[i].velocity <= IO.newline();
        }
    }
}