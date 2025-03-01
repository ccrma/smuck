@import "ezMeasure.ck"

@doc "SMucK part object. An ezPart object contains one or more ezMeasures. Measure contents can be set using the SMucKish input syntax, or when importing a MIDI file into an ezScore object."
public class ezPart
{
    // Private variables
    @doc "(hidden)"
    int _maxPolyphony;

    // Public variables
    @doc "The ezMeasure objects in the part"
    ezMeasure measures[0];

    // Constructors

    @doc "Default constructor, creates an empty part"
    fun ezPart()
    {

    }

    @doc "Create an ezPart from a SMucKish input string"
    fun ezPart(string input)
    {
        ezMeasure measure(input);
        addMeasure(measure);
    }

    //"Create an ezPart from a SMucKish input string, with fill mode"
    @doc "(hidden)"
    fun ezPart(string input, int fill_mode)
    {
        ezMeasure measure(input, fill_mode);
        addMeasure(measure);
    }

    // Public functions

    @doc "Add an ezMeasure to the part"
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

    @doc "Set the pitches of the notes in the last measure, using a SMucKish input string. If the part contains no measures, a new measure is created."
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

    @doc "Set the pitches of the notes in the last measure, using an array of SMucKish string tokens. If the part contains no measures, a new measure is created."
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

    @doc "Set the pitches of the notes in the last measure, using a 2D array of MIDI note numbers (floats). If the part contains no measures, a new measure is created."
    fun void setPitches(float input[][])
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

    @doc "(hidden)"
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

    @doc "Set the rhythms of the notes in the last measure, using a SMucKish input string. If the part contains no measures, a new measure is created."
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

    @doc "Set the rhythms of the notes in the last measure, using an array of SMucKish string tokens. If the part contains no measures, a new measure is created."
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

    @doc "Set the rhythms of the notes in the last measure, using an array of floats. If the part contains no measures, a new measure is created."
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

    @doc "(hidden)"
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

    @doc "Set the velocities of the notes in the last measure, using a SMucKish input string. If the part contains no measures, a new measure is created."
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

    @doc "Set the velocities of the notes in the last measure, using an array of SMucKish string tokens. If the part contains no measures, a new measure is created."
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

    @doc "Set the velocities of the notes in the last measure, using an array of ints. If the part contains no measures, a new measure is created."
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

    @doc "(hidden)"
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