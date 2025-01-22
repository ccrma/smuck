@import "ezMeasure.ck"

public class ezPart
{
    ezMeasure measures[0];
    int maxPolyphony;

    fun void add_measure(ezMeasure @ measure)
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
        add_measure(measure);
    }

    fun ezPart(string input, int fill_mode)
    {
        ezMeasure measure(input, fill_mode);
        add_measure(measure);
    }

    fun void set_pitches(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_pitches(input);
            add_measure(measure);
        }
        else
        {
            measures[-1].set_pitches(input);
        }
    }
    fun void set_pitches(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_pitches(input);
            add_measure(measure);
        }
        else
        {
            measures[-1].set_pitches(input);
        }
    }

    fun void set_pitches(int input[][])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_pitches(input);
            add_measure(measure);
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
            add_measure(measure);
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
            add_measure(measure);
        }
        else
        {
            measures[-1].set_rhythms(input);
        }
    }

    fun void set_rhythms(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_rhythms(input);
            add_measure(measure);
        }
        else
        {
            measures[-1].set_rhythms(input);
        }
    }

    fun void set_rhythms(float input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_rhythms(input);
            add_measure(measure);
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
            add_measure(measure);
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
            add_measure(measure);
        }
        else
        {
            measures[-1].set_velocities(input);
        }
    }

    fun void set_velocities(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_velocities(input);
            add_measure(measure);
        }
        else
        {
            measures[-1].set_velocities(input);
        }
    }

    fun void set_velocities(int input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.set_velocities(input);
            add_measure(measure);
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
            add_measure(measure);
        }
        else
        {
            measures[-1].set_velocities(input, fill_mode);
        }
    }
}