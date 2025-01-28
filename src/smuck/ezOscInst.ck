@doc "ezInstrument that uses the OscOut class to send ezNote data as OSC messages. See full class definition at https://github.com/smuck/smuck/blob/main/src/smuck/ezOscInst.ck"
public class ezOscInst extends ezInstrument
{
    // Private variables
    "localhost" => string _hostname;
    8888 => int _port;
    false => int _logOutput;

    OscOut xmit;

    // Constructors
    @doc "Default constructor. Opens an OSC connection to localhost on port 8888."
    fun ezOscInst()
    {
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    @doc "Constructor that opens an OSC connection to a given hostname and port."
    fun ezOscInst(string hostname, int port)
    {
        hostname => _hostname;
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    // Public functions
    @doc "Set the hostname to use for outgoing OSC messages."
    fun void hostname(string hostname)
    {
        hostname => _hostname;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    @doc "Get the hostname currently in use for outgoing OSC messages."
    fun string hostname()
    {
        return _hostname;
    }

    @doc "Set the port to use for outgoing OSC messages."
    fun void port(int port)
    {
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    @doc "Get the port currently in use for outgoing OSC messages."
    fun int port()
    {
        return _port;
    }

    @doc "Set whether to log outgoing note data to the console."
    fun void logOutput(int log)
    {
        log => _logOutput;
    }

    // User-overriden functions
    @doc "this noteOn() function sends an OSC message carrying pitch and velocity data from incoming ezNotes. This function uses the OSC start address '/smuck/noteOn' and adds the pitch and velocity data to the message as 'int' values. Note that here, 'voice' is passed by ezScorePlayer, but is not necessary for this kind of instrument."
    fun void noteOn(ezNote note, int voice)
    {
        xmit.start("/smuck/noteOn");
        note.pitch() => xmit.add;
        note.velocity() => xmit.add;
        xmit.send();
        if(_logOutput)
        {
            <<< "sending noteOn: pitch = ", note.pitch(), " velocity = ", note.velocity() >>>;
        }
    }

    @doc "this noteOff() function sends an OSC message carrying pitch data from incoming ezNotes. This function uses the OSC start address '/smuck/noteOff' and adds the pitch data to the message as an 'int' value. Note that here, 'voice' is passed by ezScorePlayer, but is not necessary for this kind of instrument."
    fun void noteOff(ezNote note, int voice)
    {
        xmit.start("/smuck/noteOff");
        note.pitch() => xmit.add;
        xmit.send();

        if(_logOutput)
        {
            <<<"sending noteOff: pitch = ", note.pitch() >>>;
        }
    }
}