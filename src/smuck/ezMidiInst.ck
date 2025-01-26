public class ezMidiInst extends ezInstrument
{
    // Private variables
    MidiOut mout;
    int _channel;
    int _device;

    // Public variables 
    false => int log_output;

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
    
    fun void channel(int channel)
    {
        channel => _channel;
    }

    // User-overriden functions

    fun void noteOn(ezNote note, int voice)
    {
        mout.noteOn(_channel, note.pitch, note.velocity);
        if(log_output)
        {
            <<< "noteOn: pitch = ", note.pitch, " velocity = ", note.velocity >>>;
        }
    }
    
    fun void noteOff(ezNote note, int voice)
    {
        mout.noteOff(_channel, note.pitch, 0);
        if(log_output)
        {
            <<<"noteOff: pitch = ", note.pitch >>>;
        }
    }
}