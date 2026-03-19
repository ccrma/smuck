@doc "MIDI control message (CC, Aftertouch, Pitch Bend) with onset time. Used in scores and playback alongside ezNote."
public class ezCC
{
    int _command;
    int _channel;
    int _data1;
    int _data2;

    int _isCC;               // control change (0xB)
    int _isPitchBend;        // pitch bend (0xE)
    int _isAftertouch;       // polyphonic key pressure (0xA)
    int _isChannelPressure;  // monophonic channel pressure (0xD)

    float _onset;

    fun ezCC(int command, int channel, int data1, int data2, float onset)
    {
        if (command != 0xB && command != 0xA && command != 0xD && command != 0xE)
        {
            cherr <= "ezCC: invalid command " <= command <= " (use 0xB=CC, 0xA=aftertouch, 0xD=channel pressure, 0xE=pitch bend)" <= IO.newline();
            me.exit();
        }
        if (channel < 0 || channel > 15)
        {
            cherr <= "ezCC: channel must be 0-15, got " <= channel <= IO.newline();
            me.exit();
        }
        if (data1 < 0 || data1 > 127 || data2 < 0 || data2 > 127)
        {
            cherr <= "ezCC: data1 and data2 must be 0-127, got " <= data1 <= ", " <= data2 <= IO.newline();
            me.exit();
        }
        command => _command;
        channel => _channel;
        data1 => _data1;
        data2 => _data2;
        onset => _onset;

        (command == 0xB) => _isCC;
        (command == 0xE) => _isPitchBend;
        (command == 0xA) => _isAftertouch;
        (command == 0xD) => _isChannelPressure;
    }

    @doc "Static factory: generic control change. controllerNum 0-127, value 0-127."
    fun static ezCC cc(int channel, int controllerNum, int value, float onset)
    {
        ezCC c(0xB, channel, controllerNum, value, onset);
        return c;
    }

    @doc "Static factory: modulation wheel (CC1). value 0-127."
    fun static ezCC modulation(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 1, value, onset);
        return c;
    }

    @doc "Static factory: channel volume (CC7). value 0-127."
    fun static ezCC volume(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 7, value, onset);
        return c;
    }

    @doc "Static factory: expression (CC11). value 0-127."
    fun static ezCC expression(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 11, value, onset);
        return c;
    }

    @doc "Static factory: pan (CC10). value 0-127 (64=center)."
    fun static ezCC pan(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 10, value, onset);
        return c;
    }

    @doc "Static factory: pitch bend. value 0-16383 (14-bit, 8192=center). Converts to data1 LSB, data2 MSB."
    fun static ezCC pitchBend(int channel, int value, float onset)
    {
        if (value < 0) 0 => value;
        if (value > 16383) 16383 => value;
        (value & 0x7F) => int data1;
        ((value >> 7) & 0x7F) => int data2;
        ezCC c(0xE, channel, data1, data2, onset);
        return c;
    }

    @doc "Static factory: polyphonic aftertouch (key pressure). noteNumber 0-127, pressure 0-127."
    fun static ezCC aftertouch(int channel, int noteNumber, int pressure, float onset)
    {
        ezCC c(0xA, channel, noteNumber, pressure, onset);
        return c;
    }

    @doc "Static factory: channel pressure (monophonic). pressure 0-127."
    fun static ezCC channelPressure(int channel, int pressure, float onset)
    {
        ezCC c(0xD, channel, pressure, 0, onset);
        return c;
    }

    fun int command()
    {
        return _command;
    }

    fun void command(int command)
    {
        command => _command;
    }

    fun int channel()
    {
        return _channel;
    }

    fun void channel(int channel)
    {
        channel => _channel;
    }

    fun int data1()
    {
        return _data1;
    }

    fun void data1(int data1)
    {
        data1 => _data1;
    }

    fun int data2()
    {
        return _data2;
    }

    fun void data2(int data2)
    {
        data2 => _data2;
    }

    fun float onset()
    {
        return _onset;
    }

    fun void onset(float onset)
    {
        onset => _onset;
    }

    fun int isCC()
    {
        return _isCC;
    }

    fun int isPitchBend()
    {
        return _isPitchBend;
    }

    fun int isAftertouch()
    {
        return _isAftertouch;
    }

    fun int isChannelPressure()
    {
        return _isChannelPressure;
    }

    @doc "Return 14-bit value from data1 (LSB) and data2 (MSB): (data2 << 7) | data1. Useful for pitch bend (0-16383)."
    fun int normalize2Byte()
    {
        return (_data2 << 7) | _data1;
    }

    @doc "Return a copy of the ezCC"
    fun ezCC copy()
    {
        ezCC newCC(_command, _channel, _data1, _data2, _onset);
        return newCC;
    }
}
