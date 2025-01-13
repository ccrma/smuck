@import {"smUtils.ck", "smPitch.ck", "smRhythm.ck", "smVelocity.ck"}
@import {"ezScore.ck"}

public class smScore
{
    int pitches[0][0];
    float rhythms[0];
    int velocities[0];

    fun void set_pitches(string input)
    {
        smPitch.parse_pitches(input) @=> pitches;
    }   

    fun void set_rhythms(string input)
    {
        smRhythm.parse_rhythm(input) @=> rhythms;
    }

    fun void set_velocities(string input)
    {
        smVelocity.parse_velocities(input) @=> velocities;
    }

    fun int count_notes()
    {
        int count;
        for(int i; i < pitches.size(); i++)
        {
            for(int j; j < pitches[i].size(); j++)
            {
                count++;
            }
        }
        return count;
    }

    fun ezScore to_ezScore()
    {
        ezScore score;
        ezPart part;

        // Setting score without pitch
        //--------------------------------
        if(pitches.size() == 0)
        {
            // If no rhythms are found, not enough information to create a score
            if(rhythms.size() == 0)
            {
                <<<"ERROR: No pitches or rhythms found">>>;
                return score;
            }
            // If rhythms are found, create a score with default pitch of 60
            else
            {
                ezMeasure measure;
                0.0 => float onset;

                for(int i; i < rhythms.size(); i++)
                {
                    ezNote note;
                    note.set_beats(rhythms[i]);
                    note.set_onset(onset);
                    
                    // check for velocity values
                    if(velocities.size() > 0)
                    {
                        // if velocity values are found at this position, set velocity
                        if(velocities.size() > i)
                        {
                            note.set_velocity(velocities[i]);
                        }
                        // if velocity values are not found at this position, set velocity to last velocity value
                        else
                        {
                            note.set_velocity(velocities[velocities.size() - 1]);
                        }
                    }

                    measure.add_note(note);
                    rhythms[i] +=> onset;
                }
                part.add_measure(measure);
            }
        }
        // Setting score with pitch
        //--------------------------------
        else
        {
            // If no rhythms are found, create score with default rhythms of 1.0
            if(rhythms.size() == 0)
            {
                ezMeasure measure;
                0.0 => float onset;

                for(int i; i < pitches.size(); i++)
                {
                    for(int j; j < pitches[i].size(); j++)
                    {
                        ezNote note;

                        note.set_pitch(pitches[i][j]);
                        note.set_beats(1.0);
                        note.set_onset(onset);

                        // check for velocity values
                        if(velocities.size() > 0)
                        {
                            // if velocity values are found at this position, set velocity
                            if(velocities.size() > i)
                            {
                                note.set_velocity(velocities[i]);
                            }
                            // if velocity values are not found at this position, set velocity to last velocity value
                            else
                            {
                                note.set_velocity(velocities[velocities.size() - 1]);
                            }
                        }

                        measure.add_note(note);
                        1.0 +=> onset;
                    }
                }
                part.add_measure(measure);
            }
            // Setting score with pitch and rhythms present
            //--------------------------------
            else
            {
                if(pitches.size() != rhythms.size())
                {
                    <<<"ERROR: Number of pitches and rhythms must match">>>;
                    return score;
                }
                // Number of pitches and rhythms match
                else
                {
                    ezMeasure measure;
                    0.0 => float onset;

                    for(int i; i < pitches.size(); i++)
                    {
                        for(int j; j < pitches[i].size(); j++)
                        {
                            ezNote note;
                            note.set_pitch(pitches[i][j]);
                            note.set_beats(rhythms[i]);
                            note.set_onset(onset);

                            // check for velocity values
                            if(velocities.size() > 0)
                            {
                                // if velocity values are found at this position, set velocity
                                if(velocities.size() > i)
                                {
                                    note.set_velocity(velocities[i]);
                                }
                                // if velocity values are not found at this position, set velocity to last velocity value
                                else
                                {
                                    note.set_velocity(velocities[velocities.size() - 1]);
                                }
                            }    

                            measure.add_note(note);
                            rhythms[i] +=> onset;
                        }
                    }
                    part.add_measure(measure);
                }
            }
        }

        score.parts << part;

        return score;
    }

}

