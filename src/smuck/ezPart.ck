@import "ezMeasure.ck"

public class ezPart
{
    // Private variables
    int _maxPolyphony;

    // Public variables
    ezMeasure measures[0];

    // Constructors
    fun ezPart(string input)
    {
        ezMeasure measure(input);
        addMeasure(measure);
    }

    fun ezPart(string input, int fill_mode)
    {
        ezMeasure measure(input, fill_mode);
        addMeasure(measure);
    }

    // Public functions

    fun void addMeasure(ezMeasure @ measure)
    {
        if(measures.size() == 0)
        {
            0 => measure.onset;
        }
        else
        {
            measures[-1].length() + measures[-1].onset() => measure.onset;
        }
        measures << measure;
    }

    // SMucKish input functions

    fun void setPitches(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setPitches(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setPitches(input);
        }
    }
    fun void setPitches(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setPitches(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setPitches(input);
        }
    }

    fun void setPitches(int input[][])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setPitches(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setPitches(input);
        }
    }

    fun void setPitches(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setPitches(input, fill_mode);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setPitches(input, fill_mode);
        }
    }

    fun void setRhythms(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setRhythms(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setRhythms(input);
        }
    }

    fun void setRhythms(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setRhythms(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setRhythms(input);
        }
    }

    fun void setRhythms(float input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setRhythms(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setRhythms(input);
        }
    }

    fun void setRhythms(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setRhythms(input, fill_mode);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setRhythms(input, fill_mode);
        }
    }

    fun void setVelocities(string input)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setVelocities(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setVelocities(input);
        }
    }

    fun void setVelocities(string input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setVelocities(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setVelocities(input);
        }
    }

    fun void setVelocities(int input[])
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setVelocities(input);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setVelocities(input);
        }
    }

    fun void setVelocities(string input, int fill_mode)
    {
        if(measures.size() == 0)
        {
            ezMeasure measure;
            measure.setVelocities(input, fill_mode);
            addMeasure(measure);
        }
        else
        {
            measures[-1].setVelocities(input, fill_mode);
        }
    }
}