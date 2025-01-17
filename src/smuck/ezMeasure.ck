@import "ezNote.ck"
@import "smuckish.ck"

public class ezMeasure
{
    ezNote notes[0];

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
        parse_smuckish(input);
    }

    fun void parse_smuckish(string input)
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

        if(score.pitches.size() != 0)
        {
            float onset;

            for(int i; i < score.pitches.size(); i++)
            {
                for(int j; j < score.pitches[i].size(); j++)
                {
                    ezNote note;
                    note.set_pitch(score.pitches[i][j]);
                    if(score.rhythms.size() > i)
                    {
                        note.set_beats(score.rhythms[i]);
                        note.set_onset(onset + score.rhythms[i]);
                    }
                    if(score.velocities.size() > i)
                    {
                        note.set_velocity(score.velocities[i]);
                    }
                    add_note(note);
                }
                if(score.rhythms.size() > i)
                {
                    score.rhythms[i] +=> onset;
                }
                else
                {
                    1 +=> onset;
                }
            }
            <<<"parsed ", notes.size(), " notes">>>;
            return;
        }
        else
        {
            <<<"ERROR: No pitches found in input">>>;
            return;
        }
    }
}