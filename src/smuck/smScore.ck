@import {"smUtils.ck", "smPitch.ck", "smRhythm.ck", "smVelocity.ck"}
// @import {"ezScore.ck"}

public class smScore
{
    float pitches[0][0];
    float rhythms[0];
    int velocities[0];

    fun void set_pitches(string input)
    {
        smPitch.parse_pitches(input) @=> pitches;
    }   

    fun void set_rhythms(string input)
    {
        smRhythm.parse_rhythms(input) @=> rhythms;
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
    
    fun int max_length()
    {
        return Math.max(pitches.size(), Math.max(rhythms.size(), velocities.size()));
    }

    fun void parse_interleaved(string input)
    {
        // Handle repeated sequences and tokens
        smUtils.expand_repeats(input) => string expanded;

        // Split into tokens
        smUtils.split(expanded) @=> string tokens[];

        // Tokenized input
        // string pitch_tokens[tokens.size()];
        // string rhythm_tokens[tokens.size()];
        // string velocity_tokens[tokens.size()];

        string pitch_tokens[0];
        string rhythm_tokens[0];
        string velocity_tokens[0];

        // Set current values, to be updated at each step
        "c4" => string current_pitch;
        "q" => string current_rhythm;
        "v100" => string current_velocity;

        for(int i; i < tokens.size(); i++)
        {
            tokens[i] => string token;

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
                        }
                        else
                        {
                            sub_tokens[i] => current_pitch;
                        }
                    }
                    else
                    {
                        if(smUtils.isRhythmToken(sub_tokens[i]))
                        {
                            sub_tokens[i] => current_rhythm;
                        }
                        else if(smUtils.isVelocityToken(sub_tokens[i]))
                        {
                            sub_tokens[i] => current_velocity;
                        }
                        else
                        {
                            <<<"ERROR: Invalid token: ", sub_tokens[i]>>>;
                        }
                    }
                }
            }
            else
            {
                if(!smUtils.isPitchToken(token) && !smUtils.isRhythmToken(token) && !smUtils.isVelocityToken(token))
                {
                    <<<"ERROR: Invalid token: ", token>>>;
                }
                if(smUtils.isPitchToken(token))
                {
                    token @=> current_pitch;
                }
                else if(smUtils.isRhythmToken(token))
                {
                    token @=> current_rhythm;
                }
                else if(smUtils.isVelocityToken(token))
                {
                    token @=> current_velocity;
                }

            }
            current_pitch => string temp_pitch;
            current_rhythm => string temp_rhythm;
            current_velocity => string temp_velocity;

            pitch_tokens << temp_pitch;
            if(!smUtils.isKeySigToken(temp_pitch))
            {
                rhythm_tokens << temp_rhythm;
                velocity_tokens << temp_velocity;
            }
        }

        smPitch.parse_tokens(pitch_tokens) @=> pitches;
        smRhythm.parse_tokens(rhythm_tokens) @=> rhythms;
        smVelocity.parse_tokens(velocity_tokens) @=> velocities;
    }
}

