@import {"smUtils.ck", "smPitch.ck", "smRhythm.ck", "smVelocity.ck"}
// @import {"ezScore.ck"}

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

    fun void parse_interleaved(string input)
    {
        // Parsed sequences
        int tempPitches[0][0];
        float tempRhythms[0];
        int tempVelocities[0];

        // Tokenized input
        string pitch_tokens[0];
        string rhythm_tokens[0];
        string velocity_tokens[0];

        // Handle repeated sequences and tokens
        smUtils.expand_repeats(input) => string expanded;
        // Split into tokens
        smUtils.split(expanded) @=> string tokens[];

        for(auto token : tokens)
        {
            if(token.find("|") != -1)
            {
                smUtils.split(token, "|") @=> string sub_tokens[];

                for(int i; i < sub_tokens.size(); i++)
                {
                    if(i == 0)
                    {
                        if(!smUtils.isPitchToken(sub_tokens[i]))
                        {
                            <<<"ERROR: First token must be a pitch token">>>;
                            continue;
                        }
                        else
                        {
                            pitch_tokens << sub_tokens[i];
                            continue;
                        }
                    }
                    else
                    {
                        if(smUtils.isRhythmToken(sub_tokens[i]))
                        {
                            rhythm_tokens << sub_tokens[i];
                            continue;
                        }
                        if(smUtils.isVelocityToken(sub_tokens[i]))
                        {
                            velocity_tokens << sub_tokens[i];
                            continue;
                        }
                        <<<"ERROR: Invalid token: ", sub_tokens[i]>>>;
                    }
                }
            }
            else
            {
                if(smUtils.isPitchToken(token))
                {
                    pitch_tokens << token;
                    continue;
                }
                if(smUtils.isRhythmToken(token))
                {
                    rhythm_tokens << token;
                    continue;
                }
                if(smUtils.isVelocityToken(token))
                {
                    velocity_tokens << token;
                    continue;
                }

                <<<"ERROR: Invalid token: ", token>>>;
            }
        }

        smPitch.parse_tokens(pitch_tokens) @=> pitches;
        smRhythm.parse_tokens(rhythm_tokens) @=> rhythms;
        smVelocity.parse_tokens(velocity_tokens) @=> velocities;
    }

    fun int max_length()
    {
        if(pitches.size() > rhythms.size())
        {
            if(pitches.size() > velocities.size())
            {
                return pitches.size();
            }
            else
            {
                return velocities.size();
            }
        }
        else
        {
            if(rhythms.size() > velocities.size())
            {
                return rhythms.size();
            }
            else
            {
                return velocities.size();
            }
        }
    }

    // fun ezScore to_ezScore()
    // {
    //     ezScore score;
    //     ezPart part;

    //     // Setting score without pitch
    //     //--------------------------------
    //     if(pitches.size() == 0)
    //     {
    //         // If no rhythms are found, not enough information to create a score
    //         if(rhythms.size() == 0)
    //         {
    //             <<<"ERROR: No pitches or rhythms found">>>;
    //             return score;
    //         }
    //         // If rhythms are found, create a score with default pitch of 60
    //         else
    //         {
    //             ezMeasure measure;
    //             0.0 => float onset;

    //             for(int i; i < rhythms.size(); i++)
    //             {
    //                 ezNote note;
    //                 note.set_beats(rhythms[i]);
    //                 note.set_onset(onset);
                    
    //                 // check for velocity values
    //                 if(velocities.size() > 0)
    //                 {
    //                     // if velocity values are found at this position, set velocity
    //                     if(velocities.size() > i)
    //                     {
    //                         note.set_velocity(velocities[i]);
    //                     }
    //                     // if velocity values are not found at this position, set velocity to last velocity value
    //                     else
    //                     {
    //                         note.set_velocity(velocities[velocities.size() - 1]);
    //                     }
    //                 }

    //                 measure.add_note(note);
    //                 rhythms[i] +=> onset;
    //             }
    //             part.add_measure(measure);
    //         }
    //     }
    //     // Setting score with pitch
    //     //--------------------------------
    //     else
    //     {
    //         // If no rhythms are found, create score with default rhythms of 1.0
    //         if(rhythms.size() == 0)
    //         {
    //             ezMeasure measure;
    //             0.0 => float onset;

    //             for(int i; i < pitches.size(); i++)
    //             {
    //                 for(int j; j < pitches[i].size(); j++)
    //                 {
    //                     ezNote note;

    //                     note.set_pitch(pitches[i][j]);
    //                     note.set_beats(1.0);
    //                     note.set_onset(onset);

    //                     // check for velocity values
    //                     if(velocities.size() > 0)
    //                     {
    //                         // if velocity values are found at this position, set velocity
    //                         if(velocities.size() > i)
    //                         {
    //                             note.set_velocity(velocities[i]);
    //                         }
    //                         // if velocity values are not found at this position, set velocity to last velocity value
    //                         else
    //                         {
    //                             note.set_velocity(velocities[velocities.size() - 1]);
    //                         }
    //                     }

    //                     measure.add_note(note);
    //                     1.0 +=> onset;
    //                 }
    //             }
    //             part.add_measure(measure);
    //         }
    //         // Setting score with pitch and rhythms present
    //         //--------------------------------
    //         else
    //         {
    //             if(pitches.size() != rhythms.size())
    //             {
    //                 <<<"ERROR: Number of pitches and rhythms must match">>>;
    //                 return score;
    //             }
    //             // Number of pitches and rhythms match
    //             else
    //             {
    //                 ezMeasure measure;
    //                 0.0 => float onset;

    //                 for(int i; i < pitches.size(); i++)
    //                 {
    //                     for(int j; j < pitches[i].size(); j++)
    //                     {
    //                         ezNote note;
    //                         note.set_pitch(pitches[i][j]);
    //                         note.set_beats(rhythms[i]);
    //                         note.set_onset(onset);

    //                         // check for velocity values
    //                         if(velocities.size() > 0)
    //                         {
    //                             // if velocity values are found at this position, set velocity
    //                             if(velocities.size() > i)
    //                             {
    //                                 note.set_velocity(velocities[i]);
    //                             }
    //                             // if velocity values are not found at this position, set velocity to last velocity value
    //                             else
    //                             {
    //                                 note.set_velocity(velocities[velocities.size() - 1]);
    //                             }
    //                         }    

    //                         measure.add_note(note);
    //                         rhythms[i] +=> onset;
    //                     }
    //                 }
    //                 part.add_measure(measure);
    //             }
    //         }
    //     }

    //     score.parts << part;

    //     return score;
    // }

}

