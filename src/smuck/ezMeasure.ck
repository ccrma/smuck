@import "ezNote.ck"
@import "smuckish.ck"

public class ezMeasure
{
    ezNote notes[0];
    float length;
    float onset;

    fun int numNotes()
    {
        return notes.size();
    }

    fun void add_note(ezNote note)
    {
        notes << note;
    }

    fun ezMeasure(string input)
    {
        parse_smuckish(input, 0);
    }

    fun ezMeasure(string input, int pad_mode)
    {
        parse_smuckish(input, pad_mode);
    }

    fun void parse_smuckish(string input, int pad_mode)
    {
        int pitches[0][0];
        float rhythms[0];
        int velocities[0];

        smScore score;
        score.parse_interleaved(input);
        <<<"pitches: ", score.pitches.size()>>>;
        <<<"rhythms: ", score.rhythms.size()>>>;
        <<<"velocities: ", score.velocities.size()>>>;

        if(score.pitches.size() == 0 && score.rhythms.size() == 0 && score.velocities.size() == 0)
        {
            <<<"ERROR: No pitches, rhythms, or velocities found in input">>>;
            return;
        }

        score.max_length() => int max_length;
        <<<"max_length: ", max_length>>>;

        if(!pad_mode)
        {
            [60] @=> int temp[];
            smUtils.pad_length(score.pitches, max_length, temp) @=> pitches;
            smUtils.pad_length(score.rhythms, max_length, 1) @=> rhythms;
            smUtils.pad_length(score.velocities, max_length, 100) @=> velocities;
        }
        else
        {
            if(score.pitches.size() != 0)
            {
                smUtils.pad_length(score.pitches, max_length, score.pitches[-1]) @=> pitches;
            }
            else
            {
                [60] @=> int temp[];
                smUtils.pad_length(score.pitches, max_length, temp) @=> pitches;
            }
            if(score.rhythms.size() != 0)
            {
                smUtils.pad_length(score.rhythms, max_length, score.rhythms[-1]) @=> rhythms;
            }
            else
            {
                smUtils.pad_length(score.rhythms, max_length, 1) @=> rhythms;
            }
            if(score.velocities.size() != 0)
            {
                smUtils.pad_length(score.velocities, max_length, score.velocities[-1]) @=> velocities;
            }
            else
            {
                smUtils.pad_length(score.velocities, max_length, 100) @=> velocities;
            }
        }

        <<<"pitches (padded): ", pitches.size()>>>;
        <<<"rhythms (padded): ", rhythms.size()>>>;
        <<<"velocities (padded): ", velocities.size()>>>;

        // Create notes
        float onset;

        for(int i; i < max_length; i++)
        {
            ezNote note;
            for(int j; j < pitches[i].size(); j++)
            {
                if(pitches[i][j] > 0)
                {
                    note.set_pitch(pitches[i][j]);
                    note.set_beats(rhythms[i]);
                    note.set_onset(onset);
                    note.set_velocity(velocities[i]);
                    add_note(note);
                    rhythms[i] +=> length;
                }
            }
            rhythms[i] +=> onset;
        }
    }
}