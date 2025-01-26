public class ezMidiInst extends ezInstrument
{
    // Private variables
    MidiOut mout;
    int _channel;
    int _device;
    false => int _logOutput;

    // Constructors
    fun ezMidiInst()
    {
        mout.open(0);
    }
    fun ezMidiInst(int device)
    {
        device => _device;
        mout.open(device);
    }

    // Public functions
    fun void device(int device)
    {
        device => _device;
        mout.open(device);
    }

    fun int device()
    {
        return _device;
    }
    
    fun void channel(int channel)
    {
        channel => _channel;
    }

    fun int channel()
    {
        return _channel;
    }

    fun void logOutput(int log)
    {
        log => _logOutput;
    }

    // User-overriden functions

    fun void noteOn(ezNote note, int voice)
    {
        mout.noteOn(_channel, note.pitch(), note.velocity());
        if(_logOutput)
        {
            <<< "noteOn: pitch = ", note.pitch(), " velocity = ", note.velocity() >>>;
        }
    }
    
    fun void noteOff(ezNote note, int voice)
    {
        mout.noteOff(_channel, note.pitch(), 0);
        if(_logOutput)
        {
            <<<"noteOff: pitch = ", note.pitch() >>>;
        }
    }
}