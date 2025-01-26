public class ezExternalInst extends ezInstrument
{
    // Public variables
    false => int log_output;

    // Private variables
    int _device;
    int _channel;
    "localhost" => string _hostname;
    8888 => int _port;

    MidiOut mout;
    OscOut xmit;

    false => int _useMIDI;
    false => int _useOSC;

    // Public functions
    fun void sendMIDI(int device)
    {
        true => useMIDI;
        device => _device;
        mout.open(_device);
        <<< "opening MIDI connection to device ", _device >>>;
    }

    fun void sendOSC(string hostname, int port)
    {
        true => useOSC;
        hostname => _hostname;
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host ", _hostname, " on port ", _port >>>;
    }

    fun void useMIDI(int toggle)
    {
        toggle => _useMIDI;
    }

    fun void useOSC(int toggle)
    {
        toggle => _useOSC;
    }
    
    fun void hostname(string hostname)
    {
        hostname => _hostname;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    fun void port(int port)
    {
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    fun void device(int device)
    {
        device => _device;
        mout.open(device);
    }
    
    fun void channel(int channel)
    {
        channel => _channel;
    }

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

    // send noteOn message via MIDI and/or OSC
    fun void noteOn(ezNote note, int voice)
    {
        if(_useOSC)
        {
            xmit.start("/smuck/noteOn");
            note.pitch => xmit.add;
            note.velocity => xmit.add;
            xmit.send();
        }
        if(_useMIDI)
        {
            mout.noteOn(0, note.pitch, note.velocity);
        }
        if(log_output)
        {
            <<< "sending noteOn: pitch = ", note.pitch, " velocity = ", note.velocity >>>;
        }
    }

    // send noteOff message via MIDI and/or OSC
    fun void noteOff(ezNote note, int voice)
    {
        if(_useOSC)
        {
            xmit.start("/smuck/noteOff");
            note.pitch => xmit.add;
            xmit.send();
        }
        if(_useMIDI)
        {
            mout.noteOff(0, note.pitch, 0);
        }
        if(log_output)
        {
            <<<"sending noteOff: pitch = ", note.pitch >>>;
        }
    }
}