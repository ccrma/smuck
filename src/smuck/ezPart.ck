@import "ezMeasure.ck"

@doc "SMucK part object. An ezPart object contains one or more ezMeasures. Measure contents can be set using the SMucKish input syntax, or when importing a MIDI file into an ezScore object."
public class ezPart
{
    // Private variables
    @doc "(hidden)"
    int _maxPolyphony;
    @doc "(hidden)"
    ezMeasure _measures[0];

    // Constructors
    @doc "Default constructor, creates an empty part"
    fun ezPart()
    {

    }

    @doc "Create an ezPart from a SMucKish input string"
    fun ezPart(string input)
    {
        ezMeasure measure(input);
        add(measure);
    }

    //"Create an ezPart from a SMucKish input string, with fill mode"
    @doc "(hidden)"
    fun ezPart(string input, int fill_mode)
    {
        ezMeasure measure(input, fill_mode);
        add(measure);
    }

    @doc "Create an ezPart from an array of SMucKish input strings"
    fun ezPart(string input[])
    {
        for(int i; i < input.size(); i++)
        {
            ezMeasure measure(input[i]);
            add(measure);
        }
    }

    @doc "Create an ezPart from an array of ezMeasure objects"
    fun ezPart(ezMeasure new_measures[])
    {
        new_measures @=> _measures;
    }

    // Public functions

    @doc "Get the measures in the part, as an ezMeasure array"
    fun ezMeasure[] measures()
    {
        return _measures;
    }

    @doc "Set the measures in the part, using an ezMeasure array"
    fun ezMeasure[] measures(ezMeasure measures[])
    {
        measures @=> _measures;
        return _measures;
    }

    @doc "Return a copy of the ezPart"
    fun ezPart copy()
    {
        ezPart newPart;
        _maxPolyphony => newPart._maxPolyphony;

        for(int i; i < _measures.size(); i++)
        {
            _measures[i].copy() @=> ezMeasure newMeasure;
            newPart.add(newMeasure);
        }

        return newPart;
    }

    @doc "Return a copy of the ezPart that has a subset of the measures"
    fun ezPart copy(int index, int length)
    {
        ezPart newPart;
        _maxPolyphony => newPart._maxPolyphony;

        ezMeasure new_measures[length];

        if(index < 0)
        {
            _measures.size() + 1 + index => index;
        }

        if(index < 0 || index > _measures.size())
        {
            chout <= "Cannot get measures from index " <= index <= " to " <= index + length <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            return newPart;
        }

        if(index + length > _measures.size())
        {
            chout <= "Cannot get " <= length <= " measures from index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            return newPart;
        }

        for(int i; i < length; i++)
        {
            _measures[index + i].copy() @=> new_measures[i];
        }

        new_measures @=> newPart._measures;

        return newPart;
    }

    @doc "Print the part"
    fun void print()
    {
        chout <= "--------------------------------" <= IO.newline();
        for(int i; i < _measures.size(); i++)
        {
            chout <= "Measure " <= i <= ": ";
            _measures[i].notes().size() => int num_notes;
            _measures[i].beats() => float length;
            // get polyphony
            //measures[i].getPolyphony() => int polyphony;
            chout <= " " <= num_notes <= " notes, " <= length <= " beats";
            chout <= IO.newline();
        }
        chout <= "--------------------------------" <= IO.newline();
    }
    
    @doc "Add an ezMeasure to the part"
    fun void add(ezMeasure @ measure)
    {
        insert(-1, measure);
    }

    @doc "Add an array of ezMeasures to the part"
    fun void add(ezMeasure @ new_measures[])
    {
        insert(-1, new_measures);
    }

    @doc "Insert an ezMeasure into the part at a given index"
    fun void insert(int index, ezMeasure @ new_measure)
    {
        insert(index, [new_measure]);
    }

    @doc "Insert an ezMeasure into the part at a given index, using a SMucKish input string"
    fun void insert(int index, string input)
    {
        ezMeasure new_measure(input);
        insert(index, new_measure);
    }

    @doc "Insert an array of ezMeasures into the part at a given index"
    fun void insert(int index, ezMeasure new_measures[])
    {
        if(index < 0)
        {
            _measures.size() + 1 + index => index;
        }

        if(index < 0 || index > _measures.size())
        {
            chout <= "Cannot insert measures at index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure combined_measures[_measures.size() + new_measures.size()];

        for(int i; i < new_measures.size(); i++)
        {
            new_measures[i] @=> combined_measures[index + i];
        }

        for(int i; i < _measures.size(); i++)
        {
            if(i < index)
            {
                _measures[i] @=> combined_measures[i];
            }
            else
            {
                _measures[i] @=> combined_measures[i + new_measures.size()];
            }
        }

        combined_measures @=> _measures;
    }

    @doc "Insert an array of ezMeasures into the part at a given index, using an array of SMucKish input strings"
    fun void insert(int index, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        insert(index, new_measures);
    }

    @doc "Erase an ezMeasure from the part at a given index"
    fun void erase(int index)
    {
        erase(index, 1);
    }

    @doc "Erase a range of ezMeasures from the part"
    fun void erase(int index, int length)
    {
        if(index < 0)
        {
            _measures.size() + 1 + index => index;
        }

        if(index < 0 || index > _measures.size())
        {
            chout <= "Cannot erase measures from index " <= index <= " to " <= index + length <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > _measures.size())
        {
            chout <= "Cannot erase " <= length <= " measures from index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure new_measures[_measures.size() - length];

        for(int i; i < new_measures.size(); i++)
        {
            if(i < index)
            {
                _measures[i] @=> new_measures[i];
            }
            else
            {
                _measures[i + length] @=> new_measures[i];
            }
        }

        new_measures @=> _measures;
    }

    @doc "Replace an ezMeasure in the part at a given index with a new ezMeasure"
    fun void replace(int index, ezMeasure new_measure)
    {
        replace(index, 1, [new_measure]);
    }

    @doc "Replace an ezMeasure in the part at a given index with a new ezMeasure, using a SMucKish input string"
    fun void replace(int index, string input)
    {
        ezMeasure new_measure(input);
        replace(index, 1, [new_measure]);
    }

    @doc "Replace a range of ezMeasures in the part with an array of new ezMeasures"
    fun void replace(int index, ezMeasure new_measures[])
    {
        replace(index, new_measures.size(), new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with an array of new ezMeasures"
    fun void replace(int index, int length, ezMeasure new_measures[])
    {
        erase(index, length);
        insert(index, new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with new ezMeasures, using an array of SMucKish input strings"
    fun void replace(int index, int length, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        replace(index, length, new_measures);
    }

    @doc "Replace a range of ezMeasures in the part with new ezMeasures, using an array of SMucKish input strings"
    fun void replace(int index, string inputs[])
    {
        ezMeasure new_measures[inputs.size()];
        for(int i; i < inputs.size(); i++)
        {
            ezMeasure measure(inputs[i]);
            measure @=> new_measures[i];
        }

        replace(index, new_measures.size(), new_measures);
    }

    @doc "Turn all notes in a measure at a given index into rests"
    fun void rest(int index)
    {
        rest(index, 1);
    }

    @doc "Turn all notes in a range of measures into rests"
    fun void rest(int index, int length)
    {
        if(index < 0)
        {
            _measures.size() + 1 + index => index;
        }

        if(index < 0 || index > _measures.size())
        {
            chout <= "Cannot rest measures from index " <= index <= " to " <= index + length <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > _measures.size())
        {
            chout <= "Cannot rest " <= length <= " measures from index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        for(index => int i; i < index + length; i++)
        {
            _measures[i].rest();
        }
    }

    @doc "Duplicate a range of measures n times"
    fun void duplicate(int index, int length, int n)
    {
        if(index < 0)
        {
            _measures.size() + 1 + index => index;
        }

        if(index < 0 || index > _measures.size())
        {
            chout <= "Cannot duplicate measure at index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        if(index + length > _measures.size())
        {
            chout <= "Cannot duplicate " <= length <= " measures from index " <= index <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }

        ezMeasure new_measures[length * n];
        for(int i; i < n; i++)
        {
            for(int j; j < length; j++)
            {
                _measures[index + j].copy() @=> new_measures[i * length + j];
            }
        }

        insert(index, new_measures);
    }

    @doc "Duplicate a measure n times"
    fun void duplicate(int index, int n)
    {
        duplicate(index, 1, n);
    }

}