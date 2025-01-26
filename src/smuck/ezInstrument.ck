@import "ezNote.ck";

public class ezInstrument extends Chugraph
{
    // private variables
    // --------------------------------------------------------------------------
    // number of voices
    int _numVoices;
    // array to track which voices are in use
    int voice_in_use[]; 
    // array to track which voice is assigned to which pitch
    int voice_to_pitch[];

    numVoices(127);

    // private functions
    // --------------------------------------------------------------------------
    // get the index of the first unused voice
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

        // assign the note's pitch to the voice
        theNote.pitch() => voice_to_pitch[new_voice_index];

        return new_voice_index;
    }

    // steal a voice from another note
    fun int steal_voice()
    {
        // get a random voice index
        // NOTE: could be changed to pick the oldest voice
        Math.random2(0, _numVoices - 1) => int stolen_voice_index;

        // release the voice from use
        // NOTE: This causes the stolen note to be released and noteOff to be called
        release_voice(stolen_voice_index);

        return stolen_voice_index;
    }

    // release a voice (mark it as unused, and call noteOff)
    fun void release_voice(int voice_index)
    {
        if(voice_in_use[voice_index])
        {
            // create a dummy note with the stolen note's pitch
            ezNote dummyNote;
            voice_to_pitch[voice_index] => dummyNote.pitch;

            // mark the voice as unused
            false => voice_in_use[voice_index];

            // call noteOff
            noteOff(dummyNote, voice_index);
        }
    }

    // public functions
    // --------------------------------------------------------------------------
    // set the number of voices
    fun void numVoices(int n)
    {
        n => _numVoices;
        new int[_numVoices] @=> voice_in_use;
        new int[_numVoices] @=> voice_to_pitch;
    }

    // User-overridden functions
    // --------------------------------------------------------------------------
    fun void noteOn(ezNote theNote, int voice_index)
    {
        <<< "noteOn" >>>;
    }

    fun void noteOff(ezNote theNote, int voice_index)
    {
        <<< "noteOff" >>>;
    }
}