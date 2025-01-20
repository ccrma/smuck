@import "ezMeasure.ck"

public class ezPart
{
    ezMeasure measures[0];
    int maxPolyphony;

    fun int numMeasures()
    {
        return measures.size();
    }

    fun void append_measure(ezMeasure @ measure)
    {
        if(measures.size() == 0)
        {
            0 => measure.onset;
        }
        else
        {
            measures[-1].length + measures[-1].onset => measure.onset;
        }
        measures << measure;
    }

    fun ezPart(string input)
    {
        ezMeasure measure(input);
        append_measure(measure);
    }

    fun ezPart(string input, int fill_mode)
    {
        ezMeasure measure(input, fill_mode);
        append_measure(measure);
    }

    fun void set_pitches(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_pitches(input);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_pitches(input);
        }
    }

    fun void set_pitches(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_pitches(input, fill_mode);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_pitches(input, fill_mode);
        }
    }

    fun void set_rhythms(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_rhythms(input);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_rhythms(input);
        }
    }

    fun void set_rhythms(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_rhythms(input, fill_mode);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_rhythms(input, fill_mode);
        }
    }

    fun void set_velocities(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_velocities(input);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_velocities(input);
        }
    }

    fun void set_velocities(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_velocities(input, fill_mode);
            append_measure(measure);
        }
        else
        {
            measures[-1].set_velocities(input, fill_mode);
        }
    }
}