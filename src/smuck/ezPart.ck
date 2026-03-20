@import "ezMeasure.ck"

@doc "SMucK part object. An ezPart object contains one or more ezMeasures. Measure contents can be set using the SMucKish input syntax, or when importing a MIDI file into an ezScore object."
public class ezPart
{
    // Private variables
    @doc "(hidden)"
    int _polyphony;
    @doc "(hidden)"
    string _text;
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
        polyphony();
    }

    @doc "Create an ezPart from an array of SMucKish input strings"
    fun ezPart(string input[])
    {
        for(int i; i < input.size(); i++)
        {
            ezMeasure measure(input[i]);
            add(measure);
        }
        polyphony();
    }

    @doc "Create an ezPart from an array of ezMeasure objects"
    fun ezPart(ezMeasure new_measures[])
    {
        measures(new_measures);
        polyphony();
    }

    // Public functions

    @doc "Get the length of the part in beats (sum of all measure lengths)"
    fun float beats()
    {
        cumulativeBeatsAt(_measures.size()) => float total;
        return total;
    }

    @doc "Get the measures in the part, as an ezMeasure array"
    fun ezMeasure[] measures()
    {
        return _measures;
    }

    @doc "Set the measures in the part, using an ezMeasure array. Onsets are recomputed so the timeline stays contiguous."
    fun ezMeasure[] measures(ezMeasure measures[])
    {
        measures @=> _measures;
        setOnsetsFrom(0);
        return _measures;
    }

    @doc "Get the max polyphony needed for the whole part (max over all measures' polyphony)."
    fun int polyphony()
    {
        0 => int maxP;
        for (int i; i < _measures.size(); i++)
        {
            _measures[i].polyphony() => int mp;
            if (mp > maxP) mp => maxP;
        }
        maxP => _polyphony;
        return _polyphony;
    }

    @doc "Get the text annotation of the part"
    fun string text()
    {
        return _text;
    }

    @doc "Set the text annotation of the part"
    fun string text(string value)
    {
        value => _text;
        return _text;
    }

    @doc "Return a copy of the ezPart"
    fun ezPart copy()
    {
        ezPart newPart;
        _polyphony => newPart._polyphony;
        _text => newPart._text;

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
        _polyphony => newPart._polyphony;
        _text => newPart._text;

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
        newPart.setOnsetsFrom(0);

        return newPart;
    }

    @doc "Print the part"
    fun void print()
    {
        chout <= "polyphony: " <= _polyphony <= IO.newline();
        chout <= "measures: " <= _measures.size() <= IO.newline();
        chout <= "--------------------------------" <= IO.newline();
        for(int i; i < _measures.size(); i++)
        {
            chout <= "Measure " <= i <= ": ";
            _measures[i].onset() => float onset;
            _measures[i].notes().size() => int num_notes;
            _measures[i].beats() => float length;
            // get polyphony
            //measures[i].getPolyphony() => int polyphony;
            chout <= "onset: " <= onset <= ", " <= num_notes <= " notes, " <= length <= " beats";
            chout <= IO.newline();
        }
        chout <= "--------------------------------" <= IO.newline();
    }
    
    // Returns cumulative beats at index i (sum of _measures[j].beats() for j < i)
    @doc "(hidden)"
    fun float cumulativeBeatsAt(int index)
    {
        0.0 => float sum;
        for(int j; j < index && j < _measures.size(); j++)
        {
            _measures[j].beats() +=> sum;
        }
        return sum;
    }

    // Set onsets for all measures from startIndex to end so timeline stays contiguous.
    // Uses a running sum so each measure's beats() is called at most once (O(M) instead of O(M^2)).
    @doc "(hidden)"
    fun void setOnsetsFrom(int startIndex)
    {
        if (_measures.size() <= startIndex) return;
        setOnsetsFrom(startIndex, cumulativeBeatsAt(startIndex));
    }

    // Set onsets from startIndex using startBeat as the onset of measure[startIndex]; then cumulative from there
    @doc "(hidden)"
    fun void setOnsetsFrom(int startIndex, float startBeat)
    {
        if (_measures.size() <= startIndex) return;
        startBeat => float run;
        for(int i; i < _measures.size(); i++)
        {
            if(i >= startIndex)
            {
                run => _measures[i].onset;
                _measures[i].beats() +=> run;
            }
        }
    }

    @doc "Correct misplaced notes: move each note with onset < 0 to the measure that contains its absolute start time, or clamp to 0 in the first measure. Preserves absolute time; measure lengths and onsets are recomputed. Use only when notes were incorrectly placed (e.g. after import or manual mistakes). Do NOT call on parts that use negative onset intentionally for notes tied over the barline (continuation in the next measure); calling this would move those notes and change measure boundaries."
    fun void normalizeNegativeOnsets()
    {
        if (_measures.size() == 0) return;

        float m_start[_measures.size()];
        float m_end[_measures.size()];
        for (int k; k < _measures.size(); k++)
        {
            _measures[k].onset() => m_start[k];
            m_start[k] + _measures[k].beats() => m_end[k];
        }

        int src[0], nidx[0], tgt[0];
        float newOnset[0];

        for (int i; i < _measures.size(); i++)
        {
            _measures[i].notes() @=> ezNote arr[];
            for (int j; j < arr.size(); j++)
            {
                arr[j] @=> ezNote note;
                if (note.onset() >= 0) continue;
                m_start[i] + note.onset() => float absOnset;
                if (absOnset < m_start[0])
                {
                    src << i; nidx << j; tgt << 0; newOnset << 0.0;
                }
                else
                {
                    for (int k; k < _measures.size(); k++)
                    {
                        if (absOnset >= m_start[k] && absOnset < m_end[k])
                        {
                            src << i; nidx << j; tgt << k;
                            absOnset - m_start[k] => float no;
                            newOnset << no;
                            break;
                        }
                    }
                }
            }
        }

        for (int i; i < _measures.size(); i++)
        {
            _measures[i].notes() @=> ezNote arr[];
            int n;
            arr.size() => n;
            while (n > 0)
            {
                n - 1 => int idx;
                for (int m; m < src.size(); m++)
                {
                    if (src[m] == i && nidx[m] == idx)
                    {
                        arr[idx] @=> ezNote note;
                        newOnset[m] => note.onset;
                        arr.erase(idx, idx + 1);
                        _measures[tgt[m]].add(note);
                        break;
                    }
                }
                n--;
            }
        }

        setOnsetsFrom(0);
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
        setOnsetsFrom(index);
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
        setOnsetsFrom(index);
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

    @doc "Split the measure at the given index into multiple measures by constant bar length. Replaces that measure with the result of measure.split(constantLength). Onsets are set to split-window starts (0, L, 2*L, ...) so bars align every constantLength beats. Skips empty measures. Errors if barLength <= 0."
    fun void splitMeasure(int measureIndex, float constantLength)
    {
        if (constantLength <= 0)
        {
            chout <= "splitMeasure: barLength must be positive, got " <= constantLength <= IO.newline();
            me.exit();
        }
        if(measureIndex < 0)
        {
            _measures.size() + 1 + measureIndex => measureIndex;
        }
        if(measureIndex < 0 || measureIndex >= _measures.size())
        {
            chout <= "Cannot split measure at index " <= measureIndex <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }
        if (_measures[measureIndex].beats() <= 0) return;
        _measures[measureIndex].split(constantLength) @=> ezMeasure result[];
        replace(measureIndex, 1, result);
        // Set onsets to split-window starts (0, L, 2*L, ...), not cumulative note-derived lengths
        for(int i; i < result.size(); i++)
        {
            (i * constantLength) => _measures[measureIndex + i].onset;
        }
        // Recompute onsets for measures after the split so they follow the split's end
        if(measureIndex + result.size() < _measures.size())
        {
            _measures[measureIndex + result.size() - 1].onset() + _measures[measureIndex + result.size() - 1].beats() => float nextStart;
            setOnsetsFrom(measureIndex + result.size(), nextStart);
        }
    }

    @doc "Split the measure at the given index into multiple measures by a list of bar lengths. Replaces that measure with the result of measure.split(lengths). Onsets are set to split-window starts so bars align to the given lengths. Skips empty measures. Errors if lengths array is empty."
    fun void splitMeasure(int measureIndex, float lengths[])
    {
        if (lengths.size() == 0)
        {
            chout <= "splitMeasure: lengths array must not be empty" <= IO.newline();
            me.exit();
        }
        if(measureIndex < 0)
        {
            _measures.size() + 1 + measureIndex => measureIndex;
        }
        if(measureIndex < 0 || measureIndex >= _measures.size())
        {
            chout <= "Cannot split measure at index " <= measureIndex <= " in part with " <= _measures.size() <= " measures" <= IO.newline();
            me.exit();
        }
        if (_measures[measureIndex].beats() <= 0) return;
        _measures[measureIndex].split(lengths) @=> ezMeasure result[];
        replace(measureIndex, 1, result);
        // Set onsets to split-window starts (0, L[0], L[0]+L[1], ...), using last length when list exhausted
        0.0 => float windowStart;
        for(int i; i < result.size(); i++)
        {
            windowStart => _measures[measureIndex + i].onset;
            lengths[Math.min(i, lengths.size() - 1)] +=> windowStart;
        }
        // Recompute onsets for measures after the split so they follow the split's end
        if(measureIndex + result.size() < _measures.size())
        {
            _measures[measureIndex + result.size() - 1].onset() + _measures[measureIndex + result.size() - 1].beats() => float nextStart;
            setOnsetsFrom(measureIndex + result.size(), nextStart);
        }
    }

    // Parse time signature string "num/denom" to bar length in beats (quarter = 1). Denominator is note value (4=quarter, 8=eighth).
    @doc "(hidden)"
    fun float timeSigToBarLength(string sig)
    {
        sig.find("/") => int slashIdx;
        if (slashIdx < 0)
        {
            chout <= "meter: invalid time signature '" <= sig <= "', expected num/denom (e.g. 4/4, 12/8)" <= IO.newline();
            me.exit();
        }
        sig.substring(0, slashIdx) => string numStr;
        sig.substring(slashIdx + 1, sig.length() - slashIdx - 1) => string denomStr;
        Std.atof(numStr) => float num;
        Std.atof(denomStr) => float denom;
        if (denom <= 0)
        {
            chout <= "meter: invalid time signature '" <= sig <= "', denominator must be positive" <= IO.newline();
            me.exit();
        }
        return num * (4.0 / denom);
    }

    @doc "Impose constant bar length on all measures in the part. Skips empty measures. Bar length is in beats (quarter = 1). Constant barLength may not align to musical barlines in mixed-meter parts. For large MIDI imports, calling meter() after import improves playback performance by splitting long measures."
    fun void meter(float barLength)
    {
        if (barLength <= 0)
        {
            chout <= "meter: barLength must be positive, got " <= barLength <= IO.newline();
            me.exit();
        }
        for (0 => int m; m < _measures.size(); )
        {
            if (_measures[m].beats() <= 0)
            {
                m++;
                continue;
            }
            _measures.size() => int sizeBefore;
            splitMeasure(m, barLength);
            _measures.size() - sizeBefore + 1 => int delta;
            if (delta > 0) m + delta => m;
            else m++;
        }
    }

    @doc "Impose a list of bar lengths on the part. Skips empty measures. Uses lengths in order; when exhausted, repeats last."
    fun void meter(float lengths[])
    {
        if (lengths.size() == 0)
        {
            chout <= "meter: lengths array must not be empty" <= IO.newline();
            me.exit();
        }
        for (0 => int m; m < _measures.size(); )
        {
            if (_measures[m].beats() <= 0)
            {
                m++;
                continue;
            }
            _measures.size() => int sizeBefore;
            splitMeasure(m, lengths);
            _measures.size() - sizeBefore + 1 => int delta;
            if (delta > 0) m + delta => m;
            else m++;
        }
    }

    @doc "Impose time signature on all measures. num/denom; denominator is note value (4=quarter, 8=eighth)."
    fun void meter(float num, float denom)
    {
        if (denom <= 0)
        {
            chout <= "meter: time signature denominator must be positive, got " <= denom <= IO.newline();
            me.exit();
        }
        num * (4.0 / denom) => float barLength;
        meter(barLength);
    }

    @doc "Impose variable time signatures on all measures. Each element is [num, denom]."
    fun void meter(float timeSigs[][])
    {
        if (timeSigs.size() == 0)
        {
            chout <= "meter: timeSigs array must not be empty" <= IO.newline();
            me.exit();
        }
        float lengths[0];
        for (int i; i < timeSigs.size(); i++)
        {
            if (timeSigs[i].size() < 2)
            {
                chout <= "meter: timeSigs[" <= i <= "] must have [num, denom]" <= IO.newline();
                me.exit();
            }
            if (timeSigs[i][1] <= 0)
            {
                chout <= "meter: time signature denominator must be positive" <= IO.newline();
                me.exit();
            }
            timeSigs[i][0] * (4.0 / timeSigs[i][1]) => float L;
            lengths << L;
        }
        meter(lengths);
    }

    @doc "Impose time signature from string (e.g. 4/4, 12/8) on all measures."
    fun void meter(string sig)
    {
        timeSigToBarLength(sig) => float barLength;
        meter(barLength);
    }

    @doc "Impose variable time signatures from strings (e.g. [4/4, 3/4]) on all measures."
    fun void meter(string sigs[])
    {
        if (sigs.size() == 0)
        {
            chout <= "meter: sigs array must not be empty" <= IO.newline();
            me.exit();
        }
        float lengths[0];
        for (int i; i < sigs.size(); i++)
        {
            timeSigToBarLength(sigs[i]) => float L;
            lengths << L;
        }
        meter(lengths);
    }

}