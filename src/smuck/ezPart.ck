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

    @doc "Create an ezPart from an array of SMucKish input strings"
    fun ezPart(string input[])
    {
        for(int i; i < input.size(); i++)
        {
            ezMeasure measure(input[i]);
            addMeasure(measure);
        }
    }

    @doc "Create an ezPart from an array of ezMeasure objects"
    fun ezPart(ezMeasure new_measures[])
    {
        new_measures @=> measures;
    }

    // Public functions

    @doc "Return a copy of the ezPart"
    fun ezPart copy()
    {
        ezPart newPart;
        _maxPolyphony => newPart._maxPolyphony;

        for(int i; i < measures.size(); i++)
        {
            measures[i].copy() @=> ezMeasure newMeasure;
            newPart.addMeasure(newMeasure);
        }

        return newPart;
    }

    @doc "Print the part"
    fun void print()
    {
        chout <= "--------------------------------" <= IO.newline();
        for(int i; i < measures.size(); i++)
        {
            chout <= "Measure " <= i <= ": ";
            measures[i].notes.size() => int num_notes;
            measures[i].length() => float length;
            // get polyphony
            //measures[i].getPolyphony() => int polyphony;
            chout <= " " <= num_notes <= " notes, " <= length <= " beats";
            chout <= IO.newline();
        }
        chout <= "--------------------------------" <= IO.newline();
    }
    
    @doc "Add an ezMeasure to the part"
    fun void addMeasure(ezMeasure @ measure)
    {
        insertMeasure(-1, measure);
    }

    @doc "Add an array of ezMeasures to the part"
    fun void addMeasures(ezMeasure @ measures[])
    {
        insertMeasures(-1, measures);
    }

    @doc "Insert an ezMeasure into the part at a given index"
    fun void insertMeasure(int index, ezMeasure @ new_measure)
    {
        insertMeasures(index, [new_measure]);
    }

    @doc "Insert an ezMeasure into the part at a given index, using a SMucKish input string"
    fun void insertMeasure(int index, string input)
    {
        ezMeasure measure(input);
        insertMeasure(index, measure);
    }

    @doc "Insert an array of ezMeasures into the part at a given index"
    fun void insertMeasures(int index, ezMeasure new_measures[])
    {
        if(index < 0)
        {
            measures.size() + 1 + index => index;
        }

        if(index < 0 || index > measures.size())
        {
            chout <= "Cannot insert measures at index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure combined_measures[measures.size() + new_measures.size()];

        for(int i; i < new_measures.size(); i++)
        {
            new_measures[i] @=> combined_measures[index + i];
        }

        for(int i; i < measures.size(); i++)
        {
            if(i < index)
            {
                measures[i] @=> combined_measures[i];
            }
            else
            {
                measures[i] @=> combined_measures[i + new_measures.size()];
            }
        }

        combined_measures @=> measures;
    }

    @doc "Insert an array of ezMeasures into the part at a given index, using an array of SMucKish input strings"
    fun void insertMeasures(int index, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        insertMeasures(index, new_measures);
    }

    @doc "Delete an ezMeasure from the part at a given index"
    fun void deleteMeasure(int index)
    {
        deleteMeasures(index, 1);
    }

    @doc "Delete a range of ezMeasures from the part"
    fun void deleteMeasures(int index, int length)
    {
        if(index < 0)
        {
            measures.size() + 1 + index => index;
        }

        if(index < 0 || index > measures.size())
        {
            chout <= "Cannot delete measures from index " <= index <= " to " <= index + length <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > measures.size())
        {
            chout <= "Cannot delete " <= length <= " measures from index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure new_measures[measures.size() - length];

        for(int i; i < new_measures.size(); i++)
        {
            if(i < index)
            {
                measures[i] @=> new_measures[i];
            }
            else
            {
                measures[i + length] @=> new_measures[i];
            }
        }

        new_measures @=> measures;
    }

    @doc "Replace an ezMeasure in the part at a given index with a new ezMeasure"
    fun void replaceMeasure(int index, ezMeasure new_measure)
    {
        replaceMeasures(index, 1, [new_measure]);
    }

    @doc "Replace an ezMeasure in the part at a given index with a new ezMeasure, using a SMucKish input string"
    fun void replaceMeasure(int index, string input)
    {
        ezMeasure new_measure(input);
        replaceMeasures(index, 1, [new_measure]);
    }

    @doc "Replace a range of ezMeasures in the part with an array of new ezMeasures"
    fun void replaceMeasures(int index, ezMeasure new_measures[])
    {
        replaceMeasures(index, new_measures.size(), new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with an array of new ezMeasures"
    fun void replaceMeasures(int index, int length, ezMeasure new_measures[])
    {
        deleteMeasures(index, length);
        insertMeasures(index, new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with new ezMeasures, using an array of SMucKish input strings"
    fun void replaceMeasures(int index, int length, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        replaceMeasures(index, length, new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with new ezMeasures, using an array of SMucKish input strings"
    fun void replaceMeasures(int index, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        replaceMeasures(index, new_measures.size(), new_measures);
    }

    @doc "Clear a measure at a given index"
    fun void clearMeasure(int index)
    {
        clearMeasures(index, 1);
    }

    @doc "Clear a range of measures"
    fun void clearMeasures(int index, int length)
    {
        if(index < 0)
        {
            measures.size() + 1 + index => index;
        }

        if(index < 0 || index > measures.size())
        {
            chout <= "Cannot clear measures from index " <= index <= " to " <= index + length <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > measures.size())
        {
            chout <= "Cannot clear " <= length <= " measures from index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        for(index => int i; i < index + length; i++)
        {
            measures[i].clear();
        }
    }

    @doc "Duplicate a range of measures n times"
    fun void duplicateMeasures(int index, int length, int n)
    {
        if(index < 0)
        {
            measures.size() + 1 + index => index;
        }

        if(index < 0 || index > measures.size())
        {
            chout <= "Cannot duplicate measure at index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > measures.size())
        {
            chout <= "Cannot duplicate " <= length <= " measures from index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure new_measures[length * n];
        for(int i; i < n; i++)
        {
            for(int j; j < length; j++)
            {
                measures[index + j].copy() @=> new_measures[i * length + j];
            }
        }

        insertMeasures(index, new_measures);
    }

    @doc "Duplicate a measure n times"
    fun void duplicateMeasure(int index, int n)
    {
        duplicateMeasures(index, 1, n);
    }

    @doc "Return a copy of a range of measures"
    fun ezMeasure[] getMeasures(int index, int length)
    {
        ezMeasure new_measures[length];

        if(index < 0)
        {
            measures.size() + 1 + index => index;
        }

        if(index < 0 || index > measures.size())
        {
            chout <= "Cannot get measures from index " <= index <= " to " <= index + length <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            return new_measures;
        }

        if(index + length > measures.size())
        {
            chout <= "Cannot get " <= length <= " measures from index " <= index <= " in part with " <= measures.size() <= " measures" <= IO.newline();
            return new_measures;
        }

        for(int i; i < length; i++)
        {
            measures[index + i].copy() @=> new_measures[i];
        }

        return new_measures;
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

    @doc "Set the pitches of the notes in the last measure, using a 2D array of MIDI note numbers. If the part contains no measures, a new measure is created."
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
    fun void setVelocities(float input[])
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