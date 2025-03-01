@import "ezNote.ck";

@doc "Base class for user-defined instruments to be used for playback in ezScorePlayer. Users should extend this base class to create their own instruments. Users define the behavior of their instrument by overriding the noteOn and noteOff functions."
public class ezInstrument extends Chugraph
{
    // private variables
    // --------------------------------------------------------------------------
    // number of voices
    @doc "(hidden)"
    int _numVoices;

    // array to track which voices are in use
    @doc "(hidden)"
    int voice_in_use[]; 

    // array to track which voice is assigned to which pitch
    @doc "(hidden)"
    ezNote voice_to_note[];

    // array to track order of voices used
    int voice_order[0];

    setVoices(16);

    // private functions
    // --------------------------------------------------------------------------
    // get the index of the first unused voice
    @doc "(hidden)"
    fun int get_free_voice()
    {
        for(int i; i < _numVoices; i++)
        {
            if(!voice_in_use[i])
            {
                return i;
            }
        }
        return -1;
    }

    // allocate a voice for a new incoming note
    @doc "(hidden)"
    fun int allocate_voice(ezNote theNote)
    {
        // get the first free voice 
        get_free_voice() => int new_voice_index;

        // if there are no free voices, steal one
        if(new_voice_index == -1)
        {
            steal_voice() => new_voice_index;
        }

        // mark the voice as in use
        true => voice_in_use[new_voice_index];

        // add voice index to voice order tracker
        voice_order << new_voice_index;

        // assign the note's pitch to the voice
        theNote @=> voice_to_note[new_voice_index];

        return new_voice_index;
    }

    // steal a voice from another note
    @doc "(hidden)"
    fun int steal_voice()
    {
        // get a random voice index (NOTE: deprecated)
        // Math.random2(0, _numVoices - 1) => int stolen_voice_index;

        // Get the oldest voice
        voice_order[0] => int stolen_voice_index;
        voice_order.popFront();

        // release the voice from use
        // NOTE: This causes the stolen note to be released (noteOff is not called)
        release_voice(stolen_voice_index);

        return stolen_voice_index;
    }

    // release a voice (mark it as unused, and call noteOff)
    @doc "(hidden)"
    fun void release_voice(int voice_index)
    {
        // noteOff(voice_to_note[voice_index], voice_index);

        if(voice_in_use[voice_index])
        {
            // mark the voice as unused
            false => voice_in_use[voice_index];

            // call noteOff
            // noteOff(voice_to_note[voice_index], voice_index);
        }

        // Update the voice order queue
        for(int i; i < voice_order.size(); i++)
        {
            if(voice_order[i] == voice_index)
            {
                voice_order.erase(i);
            }
        }
    }

    // public functions
    // --------------------------------------------------------------------------
    @doc "Set the number of voices for the instrument if using user-defined signal chain. This tells the ezScorePlayer how many voices to allocate for the instrument. E.g. if you set up 5 SinOscs, you should call setVoices(5) inside your class definition. See ezDefaultInst.ck for an example."
    fun void setVoices(int n_voices)
    {
        n_voices => _numVoices;
        new int[_numVoices] @=> voice_in_use;
        new ezNote[_numVoices] @=> voice_to_note;
    }

    // User-overridden functions
    // --------------------------------------------------------------------------
    @doc "This function defines behavior that will be executed when a note is played by the ezScorePlayer. Typically, this would include setting frequency, gain, calling .keyOn(), etc. by referencing variables of theNote. The base class function is empty, and should be overridden by the user."
    fun void noteOn(ezNote note, int voice)
    {
        <<< "Implement this noteOn function" >>>;
    }

    @doc "This function defines behavior that will be executed when a note is released by the ezScorePlayer. This could include calling .keyOff(), etc. or referencing variables of theNote. The base class function is empty, and should be overridden by the user."
    fun void noteOff(ezNote note, int voice)
    {
        <<< "Implement this noteOff function" >>>;
    }
}