@import "ezNote.ck"
@import "Smuckish.ck" // for recursive imports

@doc "SMucK measure object. An ezMeasure object contains one or more ezNotes. Note contents can be set using the SMucKish input syntax."
public class ezMeasure
{
    // Private variables
    @doc "(hidden)"
    float _pitches[0][0];
    @doc "(hidden)"
    float _rhythms[0];
    @doc "(hidden)"
    float _velocities[0];

    @doc "(hidden)"
    ezNote _notes[0];
    
    // Constructors
    @doc "Default constructor, creates an empty measure"
    fun ezMeasure()
    {

    }

    @doc "Create an ezMeasure from a SMucKish input string"
    fun ezMeasure(string input)
    {
        setInterleaved(input);
    }

    //"Create an ezMeasure from a SMucKish input string, with fill mode"
    @doc "(hidden)" 
    fun ezMeasure(string input, int fill_mode)
    {
        setInterleaved(input, fill_mode);
    }

    @doc "Return a copy of the ezMeasure"
    fun ezMeasure copy()
    {
        ezMeasure newMeasure;

        for(int i; i < _notes.size(); i++)
        {
            _notes[i].copy() @=> ezNote newNote;
            newMeasure._notes << newNote;
        }

        return newMeasure;
    }

    // Public functions
    @doc "Add an ezNote to the measure"
    fun void add(ezNote note)
    {
        _notes << note;
    }
    
    @doc "Add an array of ezNotes to the measure"
    fun void add(ezNote notes[])
    {
        for(int i; i < notes.size(); i++)
        {
            _notes << notes[i];
        }
    }

    @doc "Sort the notes array in place by onset time"
    fun void sort()
    {
        // Quicksort implementation
        if(_notes.size() > 1)
        {
            quicksort(_notes, 0, _notes.size()-1);
        }
    }
    
    @doc "Print the parameters for each note in the measure"
    fun void print()
    {
        chout <= "--------------------------------" <= IO.newline();
        for(int i; i < _notes.size(); i++)
        {
            chout <= "Note " <= i <= ": ";
            _notes[i].printLine();
        }
        chout <= "--------------------------------" <= IO.newline();
    }

    // Member variable get/set functions

    @doc "Get the notes in the measure as an ezNote array"
    fun ezNote[] notes()
    {
        return _notes;
    }

    @doc "Set the notes of the measure using an ezNote array"
    fun ezNote[] notes(ezNote notes[])
    {
        notes @=> _notes;
        return _notes;
    }

    @doc "Get the length of the measure in beats"
    fun float beats()
    {
        float length;
        for(int i; i < _notes.size(); i++)
        {
            _notes[i].onset() + _notes[i].beats() => float note_length;
            if(note_length > length)
            {
                note_length => length;
            }
        }
        return length;
    }

    @doc "(hidden)"
    fun int getPolyphony()
    {
        // TODO: Implement this
        return 0;
    }

    @doc "Set all notes to rests"
    fun void rest()
    {
        _notes.size() => int num_notes;
        for(int i; i < num_notes; i++)
        {
            true => _notes[i].isRest;
        }
    }

    // SMucKish parsing functions

    @doc "Get the pitches of the notes in the measure as a 2D array of MIDI note numbers"
    fun float[][] pitches()
    {
        return _pitches;
    }

    @doc "Set the pitches of the notes in the measure, using a SMucKish input string"
    fun float[][] pitches(string input)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _pitches;
    }
    
    @doc "Set the pitches of the notes in the measure, using an array of SMucKish string tokens"
    fun float[][] pitches(string input[])
    {
        smPitch.parse_tokens(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _pitches;
    }

    @doc "Set the pitches of the notes in the measure directly from a 2D array of MIDI note numbers"
    fun float[][] pitches(float input[][])
    {
        input @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _pitches;
    }

    @doc "Get the rhythms of the notes in the measure as an array of floats"
    fun float[] rhythms()
    {
        return _rhythms;
    }

    @doc "Set the rhythms of the notes in the measure, using a SMucKish input string"
    fun float[] rhythms(string input)
    {   
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _rhythms;
    }

    @doc "Set the rhythms of the notes in the measure, using an array of SMucKish string tokens"
    fun float[] rhythms(string input[])
    {
        smRhythm.parse_tokens(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _rhythms;
    }

    @doc "Set the rhythms of the notes in the measure directly from an array of floats"
    fun float[] rhythms(float input[])
    {
        input @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _rhythms;
    }

    @doc "Get the velocities of the notes in the measure as an array of floats"
    fun float[] velocities()
    {
        return _velocities;
    }

    @doc "Set the velocities of the notes in the measure, using a SMucKish input string"
    fun float[] velocities(string input)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _velocities;
    }

    @doc "Set the velocities of the notes in the measure, using an array of SMucKish string tokens"
    fun float[] velocities(string input[])
    {
        smVelocity.parse_tokens(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _velocities;
    }

    @doc "Set the velocities of the notes in the measure directly from an array of floats"
    fun float[] velocities(float input[])
    {
        input @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, 1);

        return _velocities;
    }

    // Set pitches from a string, with fill mode
    @doc "(hidden)"
    fun float[][] pitches(string input, int fill_mode)
    {
        smPitch.parse_pitches(input) @=> _pitches;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);

        return _pitches;
    }

    // Set rhythms from a string, with fill mode
    @doc "(hidden)"
    fun float[] rhythms(string input, int fill_mode)
    {
        smRhythm.parse_rhythms(input) @=> _rhythms;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);

        return _rhythms;
    }

    // Set velocities from a string, with fill mode
    @doc "(hidden)"
    fun float[] velocities(string input, int fill_mode)
    {
        smVelocity.parse_velocities(input) @=> _velocities;
        compile_notes(_pitches, _rhythms, _velocities, fill_mode);

        return _velocities;
    }

    // Private functions

    // Helper function for quicksort
    @doc "(hidden)"
    fun void quicksort(ezNote arr[], int low, int high)
    {
        if(low < high)
        {
            // Get partition index
            partition(arr, low, high) => int ix;

            // Recursively sort elements before and after partition
            quicksort(arr, low, ix-1);
            quicksort(arr, ix+1, high);
        }
    }

    // Helper function for quicksort partition
    @doc "(hidden)" 
    fun int partition(ezNote arr[], int low, int high)
    {
        // Use rightmost element as pivot
        arr[high].onset() => float pivot;
        
        // Index of smaller element
        low - 1 => int i;

        // Compare each element with pivot
        for(int j; j < high; j++)
        {
            if(arr[j].onset() <= pivot)
            {
                i++;
                // Swap elements
                arr[i] @=> ezNote temp;
                arr[j] @=> arr[i];
                temp @=> arr[j];
            }
        }

        // Put pivot in correct position
        arr[i+1] @=> ezNote temp;
        arr[high] @=> arr[i+1];
        temp @=> arr[high];

        return i+1;
    }
    @doc "(hidden)"
    fun void setInterleaved(string input)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, 1);
    }

    @doc "(hidden)"
    fun void setInterleaved(string input, int fill_mode)
    {
        smScore score;
        score.parse_interleaved(input);
        compile_notes(score.pitches, score.rhythms, score.velocities, fill_mode);
    }

    @doc "(hidden)"
    fun float[] get_new_chord(float new_pitches[][], float context_chord[], int index, int fill_mode)
    {
        if(new_pitches.size() > index)
        {
            return new_pitches[index];
        }
        else
        {
            if(fill_mode == 1)
            {
                return context_chord;
            }
            else
            {
                return [60.0];
            }
        }
    }

    @doc "(hidden)"
    fun float get_new_rhythm(float new_rhythms[], float context_rhythm, int index, int fill_mode)
    {
        if(new_rhythms.size() > index)
        {
            return new_rhythms[index];
        }
        else
        {
            if(fill_mode == 1)
            {
                return context_rhythm;
            }
            else
            {
                return 1.0;
            }
        }
    }

    @doc "(hidden)"
    fun float get_new_velocity(float new_velocities[], float context_velocity, int index, int fill_mode)
    {
        if(new_velocities.size() > index)
        {
            return new_velocities[index];
        }
        else
        {
            if(fill_mode == 1)
            {
                return context_velocity;
            }
            else
            {
                return 1.0;
            }
        }
    }
    @doc "(hidden)"
    fun void compile_notes(float new_pitches[][], float new_rhythms[], float new_velocities[], int fill_mode)
    {
        ezNote new_notes[0];

        float temp_pitches[0][0];
        float temp_rhythms[0];
        float temp_velocities[0];

        [60.0] @=> float context_chord[];
        1.0 => float context_rhythm;
        1.0 => float context_velocity;
        0.0 => float context_onset;

        Math.max(new_pitches.size(), Math.max(new_rhythms.size(), new_velocities.size())) => int max_length;

        if(max_length == 0)
        {
            <<<"ERROR: No pitches, rhythms, or velocities found in input">>>;
            return;
        }

        for(int i; i < max_length; i++)
        {
            get_new_chord(new_pitches, context_chord, i, fill_mode) @=> context_chord;
            get_new_rhythm(new_rhythms, context_rhythm, i, fill_mode) => context_rhythm;
            get_new_velocity(new_velocities, context_velocity, i, fill_mode) => context_velocity;

            // If the chord is empty, create a rest ezNote
            if(context_chord.size() == 0)
            {
                ezNote note;
                note.onset(context_onset);
                note.beats(context_rhythm);
                note.velocity(context_velocity);
                note.isRest(true);

                new_notes << note;
            }

            for (0 => int j; j < context_chord.size(); j++)
            {
                ezNote note;
                note.onset(context_onset);
                note.beats(context_rhythm);
                note.pitch(context_chord[j]);
                note.velocity(context_velocity);
                note.isRest(false);

                new_notes << note;
            }

            context_rhythm +=> context_onset;

            temp_pitches << context_chord;
            temp_rhythms << context_rhythm;
            temp_velocities << context_velocity;
        }

        // Copy the new notes to the notes array
        new_notes @=> _notes;

        // Copy the temp arrays to the global arrays
        temp_pitches @=> _pitches;
        temp_rhythms @=> _rhythms;
        temp_velocities @=> _velocities;
    }
}