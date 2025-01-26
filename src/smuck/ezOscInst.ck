public class ezOscInst extends ezInstrument
{
    // Public variables
    false => int log_output;

    // Private variables
    "localhost" => string _hostname;
    8888 => int _port;
    OscOut xmit;

    // Constructors
    fun ezOscInst()
    {
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }
    fun ezOscInst(string hostname, int port)
    {
        hostname => _hostname;
        port => _port;
        xmit.dest(_hostname, _port);
        <<< "opening OSC connection to host", _hostname, "on port", _port >>>;
    }

    // Public functions
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

    // User-overriden functions
    fun void noteOn(ezNote note, int voice)
    {
        xmit.start("/smuck/noteOn");
        note.pitch => xmit.add;
        note.velocity => xmit.add;
        xmit.send();
        if(log_output)
        {
            <<< "sending noteOn: pitch = ", note.pitch, " velocity = ", note.velocity >>>;
        }
    }

    fun void noteOff(ezNote note, int voice)
    {
        xmit.start("/smuck/noteOff");
        note.pitch => xmit.add;
        xmit.send();

        if(log_output)
        {
            <<<"sending noteOff: pitch = ", note.pitch >>>;
        }
    }
}