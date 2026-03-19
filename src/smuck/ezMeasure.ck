@import "ezNote.ck"
@import "ezCC.ck"
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

    @doc "(hidden)"
    ezCC _ccs[0];

    @doc "(hidden)"
    0.0 => float _onset;

    @doc "(hidden)"
    string _text;

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

    @doc "Create an ezMeasure from an array of ezNote objects"
    fun ezMeasure(ezNote notes[])
    {
        this.notes(notes);
    }

    @doc "Return a copy of the ezMeasure"
    fun ezMeasure copy()
    {
        ezMeasure newMeasure;
        _onset => newMeasure._onset;
        _text => newMeasure._text;

        for(int i; i < _notes.size(); i++)
        {
            _notes[i].copy() @=> ezNote newNote;
            newMeasure._notes << newNote;
        }

        for(int i; i < _ccs.size(); i++)
        {
            _ccs[i].copy() @=> ezCC newCC;
            newMeasure._ccs << newCC;
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

    @doc "Add an ezCC to the measure"
    fun void add(ezCC cc)
    {
        _ccs << cc;
    }

    @doc "Add an array of ezCCs to the measure"
    fun void add(ezCC ccs[])
    {
        for(int i; i < ccs.size(); i++)
        {
            _ccs << ccs[i];
        }
    }

    @doc "Sort the notes and CCs arrays in place by onset time"
    fun void sort()
    {
        // Quicksort for notes
        if(_notes.size() > 1)
        {
            quicksort(_notes, 0, _notes.size()-1);
        }
        // Insertion sort for CCs (typically few per measure)
        for(int i; i < _ccs.size(); i++)
        {
            _ccs[i] @=> ezCC key;
            i - 1 => int j;
            while(j >= 0 && _ccs[j].onset() > key.onset())
            {
                _ccs[j] @=> _ccs[j+1];
                j--;
            }
            key @=> _ccs[j+1];
        }
    }
    
    @doc "Print the parameters for each note in the measure"
    fun void print()
    {
        chout <= "onset: " <= _onset <= IO.newline();
        chout <= "beats: " <= beats() <= IO.newline();
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

    @doc "Get the CCs in the measure as an ezCC array"
    fun ezCC[] ccs()
    {
        return _ccs;
    }

    @doc "Set the CCs of the measure using an ezCC array"
    fun ezCC[] ccs(ezCC ccs[])
    {
        ccs @=> _ccs;
        return _ccs;
    }

    @doc "Get the onset of the measure in beats (start time within the part)"
    fun float onset()
    {
        return _onset;
    }

    @doc "Set the onset of the measure in beats (start time within the part)"
    fun float onset(float value)
    {
        value => _onset;
        return _onset;
    }

    @doc "Get the text annotation of the measure"
    fun string text()
    {
        return _text;
    }

    @doc "Set the text annotation of the measure"
    fun string text(string value)
    {
        value => _text;
        return _text;
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


    @doc "Get the max number of concurrent (sounding) voices in the measure. Rest notes are not counted."
    fun int polyphony()
    {
        float eventTimes[0];
        int eventDeltas[0];
        for (int i; i < _notes.size(); i++)
        {
            if (_notes[i].isRest()) continue;
            _notes[i].onset() => float start;
            _notes[i].onset() + _notes[i].beats() => float end;
            eventTimes << start;
            eventDeltas << 1;
            eventTimes << end;
            eventDeltas << -1;
        }
        if (eventTimes.size() == 0)
        {
            return 0;
        }
        sortEvents(eventTimes, eventDeltas);
        0 => int count;
        0 => int maxCount;
        for (int i; i < eventTimes.size(); i++)
        {
            eventDeltas[i] +=> count;
            if (count > maxCount) count => maxCount;
        }
        return maxCount;
    }

    @doc "Split the measure into multiple measures by constant bar length. Returns an array of ezMeasure. Each resulting measure contains notes whose onset falls in that window; note onsets are relative to the new measure. Remainder at end becomes a shorter final measure. Empty windows create an empty measure."
    fun ezMeasure[] split(float constantLength)
    {
        this.beats() => float measure_end;
        if (constantLength <= 0 || measure_end <= 0)
        {
            ezMeasure empty[0];
            return empty;
        }

        (measure_end / constantLength) $ int => int num_windows;
        if (num_windows * constantLength < measure_end) num_windows++;

        ezMeasure result[num_windows];
        for(int i; i < num_windows; i++)
        {
            ezMeasure m;
            m @=> result[i];
        }

        for(int j; j < _notes.size(); j++)
        {
            _notes[j] @=> ezNote note;
            (note.onset() / constantLength) $ int => int window_id;
            if (window_id >= num_windows) num_windows - 1 => window_id;
            note.onset() - (window_id * constantLength) => float relative_onset;

            note.copy() @=> ezNote newNote;
            newNote.onset(relative_onset);
            result[window_id].add(newNote);
        }

        for(int j; j < _ccs.size(); j++)
        {
            _ccs[j] @=> ezCC cc;
            (cc.onset() / constantLength) $ int => int window_id;
            if (window_id >= num_windows) num_windows - 1 => window_id;
            cc.onset() - (window_id * constantLength) => float relative_onset;

            cc.copy() @=> ezCC newCC;
            newCC.onset(relative_onset);
            result[window_id].add(newCC);
        }
        return result;
    }

    // Largest window index i such that boundaries[i] <= t; boundaries[0..num_windows-1] are window starts
    @doc "(hidden)"
    fun int findWindowForOnset(float t, float boundaries[], int num_windows)
    {
        if (num_windows <= 0) return 0;
        if (t <= boundaries[0]) return 0;
        0 => int low;
        num_windows => int high;
        while (low < high - 1)
        {
            ((low + high) / 2) $ int => int mid;
            if (boundaries[mid] <= t)
                mid => low;
            else
                mid => high;
        }
        return low;
    }

    @doc "Split the measure into multiple measures by a list of bar lengths. Uses list in order; if list is exhausted, uses the last element for remainder. If list is longer than material, creates only as many measures as needed. Empty windows create an empty measure."
    fun ezMeasure[] split(float lengths[])
    {
        this.beats() => float measure_end;
        if (lengths.size() == 0 || measure_end <= 0)
        {
            ezMeasure empty[0];
            return empty;
        }

        float boundaries[0];
        0.0 => float start;
        0 => int listIndex;
        while (start < measure_end)
        {
            boundaries << start;
            lengths[Math.min(listIndex, lengths.size() - 1)] => float L;
            L => float window_length;
            if (start + L > measure_end) measure_end - start => window_length;
            window_length +=> start;
            listIndex++;
        }
        boundaries.size() => int num_windows;

        ezMeasure result[num_windows];
        for(int i; i < num_windows; i++)
        {
            ezMeasure m;
            m @=> result[i];
        }

        for(int j; j < _notes.size(); j++)
        {
            _notes[j] @=> ezNote note;
            findWindowForOnset(note.onset(), boundaries, num_windows) => int window_id;
            if (window_id >= num_windows) num_windows - 1 => window_id;
            note.onset() - boundaries[window_id] => float relative_onset;

            note.copy() @=> ezNote newNote;
            newNote.onset(relative_onset);
            result[window_id].add(newNote);
        }

        for(int j; j < _ccs.size(); j++)
        {
            _ccs[j] @=> ezCC cc;
            findWindowForOnset(cc.onset(), boundaries, num_windows) => int window_id;
            if (window_id >= num_windows) num_windows - 1 => window_id;
            cc.onset() - boundaries[window_id] => float relative_onset;

            cc.copy() @=> ezCC newCC;
            newCC.onset(relative_onset);
            result[window_id].add(newCC);
        }
        return result;
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

    // NOTE: Need to add get functions for pitches, rhythms, and velocities that will work if the measure was constructed from ezNotes, not SMucKish input (i.e. if from serialized data)

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

    // Sort (eventTimes, eventDeltas) by time; at same time, end events (-1) before start (1)
    @doc "(hidden)"
    fun void sortEvents(float times[], int deltas[])
    {
        for (int i; i < times.size() - 1; i++)
        {
            for (int j; j < times.size() - 1 - i; j++)
            {
                if (times[j] > times[j+1] || (times[j] == times[j+1] && deltas[j] > deltas[j+1]))
                {
                    times[j] => float t;
                    times[j+1] => times[j];
                    t => times[j+1];
                    deltas[j] => int d;
                    deltas[j+1] => deltas[j];
                    d => deltas[j+1];
                }
            }
        }
    }

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