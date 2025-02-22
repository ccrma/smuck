@doc "ezInstrument that uses the MidiOut class to send ezNote data as MIDI messages."
public class ezMidiInst extends ezInstrument
{
    // Private variables
    MidiOut mout;
    int _channel;
    int _device;
    false => int _logOutput;

    // Constructors
    @doc "Default constructor. Opens MIDI device 0 and sets channel to 0."
    fun ezMidiInst()
    {
        mout.open(0);
    }

    @doc "Constructor that opens a given MIDI device."
    fun ezMidiInst(int device)
    {
        device => _device;
        mout.open(device);
    }

    // Public functions
    @doc "Set the MIDI device to use."
    fun void device(int device)
    {
        device => _device;
        mout.open(device);
    }

    @doc "Get the MIDI device currently in use."
    fun int device()
    {
        return _device;
    }

    @doc "Set the MIDI channel to use."
    fun void channel(int channel)
    {
        channel => _channel;
    }

    @doc "Get the MIDI channel currently in use."
    fun int channel()
    {
        return _channel;
    }

    @doc "Set whether to log outgoing note data to the console."
    fun void logOutput(int log)
    {
        log => _logOutput;
    }
    
    @doc "Flush the MIDI device by sending a noteOn and noteOff message for each MIDI channel and note."
    fun void flushMIDI()
    {
        for(int i; i < 16; i++)
        {
            for(int j; j < 128; j++)
            {
                <<< "flushing MIDI: ", i, " ", j >>>;
                mout.noteOn(i, j, 0);
                mout.noteOff(i, j, 100);
            }
        }
    }
    // User-overriden functions
    @doc "this noteOn() function sends a MIDI noteOn message carrying pitch and velocity data from incoming ezNotes. Note that here, 'voice' is passed by ezScorePlayer, but is not necessary for this kind of instrument."
    fun void noteOn(ezNote note, int voice)
    {
        mout.noteOn(_channel, note.pitch(), note.velocity());
        if(_logOutput)
        {
            <<< "noteOn: pitch = ", note.pitch(), " velocity = ", note.velocity() >>>;
        }
    }

    @doc "this noteOff() function sends a MIDI noteOff message carrying pitch data from incoming ezNotes. Note that here, 'voice' is passed by ezScorePlayer, but is not necessary for this kind of instrument."
    fun void noteOff(ezNote note, int voice)
    {
        mout.noteOff(_channel, note.pitch(), 0);
        if(_logOutput)
        {
            <<<"noteOff: pitch = ", note.pitch() >>>;
        }
    }
}