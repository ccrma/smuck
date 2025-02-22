@doc "ezInstrument that sends note data to an external MIDI and/or OSC device. Meant for sending data to external devices/software."
public class ezExternalInst extends ezInstrument
{
    // Private variables
    @doc "(hidden)"
    int _device;

    @doc "(hidden)"
    int _channel;

    @doc "(hidden)"
    "localhost" => string _hostname;

    @doc "(hidden)"
    8888 => int _port;

    @doc "(hidden)"
    false => int _logOutput;

    @doc "(hidden)"
    MidiOut mout;

    @doc "(hidden)"
    OscOut xmit;

    @doc "(hidden)"
    false => int _useMIDI;

    @doc "(hidden)"
    false => int _useOSC;

    // Public functions
    @doc "Set the MIDI device to use and enable MIDI output."
    fun void sendMIDI(int device)
    {
        true => useMIDI;
        device => _device;
        mout.open(_device);
        <<< "opening MIDI connection to device ", _device >>>;
    }

    @doc "Set the OSC hostname and port to use and enable OSC output."
    fun void sendOSC(string hostname, int port)
    {
        true => useOSC;
        hostname => _hostname;
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host ", _hostname, " on port ", _port >>>;
    }

    @doc "Set whether to send note data via MIDI."
    fun void useMIDI(int toggle)
    {
        toggle => _useMIDI;
    }

    @doc "Set whether to send note data via OSC."
    fun void useOSC(int toggle)
    {
        toggle => _useOSC;
    }
    
    @doc "Set the OSC hostname to use."
    fun void hostname(string hostname)
    {
        hostname => _hostname;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    @doc "Get the OSC hostname currently in use."
    fun string hostname()
    {
        return _hostname;
    }

    @doc "Set the OSC port to use."
    fun void port(int port)
    {
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    @doc "Get the OSC port currently in use."
    fun int port()
    {
        return _port;
    }

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

    // send noteOn message via MIDI and/or OSC
    @doc "Send a noteOn message via MIDI and/or OSC."
    fun void noteOn(ezNote note, int voice)
    {
        if(_useOSC)
        {
            xmit.start("/smuck/noteOn");
            note.pitch() => xmit.add;
            note.velocity() => xmit.add;
            xmit.send();
        }
        if(_useMIDI)
        {
            mout.noteOn(0, note.pitch(), note.velocity());
        }
        if(_logOutput)
        {
            <<< "sending noteOn: pitch = ", note.pitch(), " velocity = ", note.velocity() >>>;
        }
    }

    // send noteOff message via MIDI and/or OSC
    @doc "Send a noteOff message via MIDI and/or OSC."
    fun void noteOff(ezNote note, int voice)
    {
        if(_useOSC)
        {
            xmit.start("/smuck/noteOff");
            note.pitch() => xmit.add;
            xmit.send();
        }
        if(_useMIDI)
        {
            mout.noteOff(0, note.pitch(), 0);
        }
        if(_logOutput)
        {
            <<<"sending noteOff: pitch = ", note.pitch() >>>;
        }
    }
}