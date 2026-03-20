@doc "MIDI control message (CC, Aftertouch, Pitch Bend) with onset time. Used in scores and playback alongside ezNote."
public class ezCC
{
    @doc "(hidden)"
    int _command;
    @doc "(hidden)"
    int _channel;
    @doc "(hidden)"
    int _data1;
    @doc "(hidden)"
    int _data2;
    @doc "(hidden)"
    int _isCC;               // control change (11)
    @doc "(hidden)"
    int _isPitchBend;        // pitch bend (14)
    @doc "(hidden)"
    int _isAftertouch;       // polyphonic key pressure (10)
    @doc "(hidden)"
    int _isChannelPressure;  // monophonic channel pressure (13)

    @doc "(hidden)"
    float _onset;

    @doc "Create ezCC. command: 11 = CC, 10 = aftertouch, 13 = channel pressure, 14 = pitch bend. channel: 0-15. data1, data2: 0-127."
    fun ezCC(int command, int channel, int data1, int data2, float onset)
    {
        if (command != 0xB && command != 0xA && command != 0xD && command != 0xE)
        {
            cherr <= "ezCC: invalid command " <= command <= " (use 11 = CC, 10 = aftertouch, 13 = channel pressure, 14 = pitch bend)" <= IO.newline();
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

    @doc "Static factory method for creating a control change ezCC object. Set channel: 0-15, controllerNum: 0-127, value: 0-127, onset: time in beats."
    fun static ezCC cc(int channel, int controllerNum, int value, float onset)
    {
        ezCC c(0xB, channel, controllerNum, value, onset);
        return c;
    }

    @doc "Static factory method for creating a modulation wheel ezCC object. Set channel: 0-15, value: 0-127, onset: time in beats."
    fun static ezCC modulation(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 1, value, onset);
        return c;
    }

    @doc "Static factory method for creating a channel volume ezCC object. Set channel: 0-15, value: 0-127, onset: time in beats."
    fun static ezCC volume(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 7, value, onset);
        return c;
    }

    @doc "Static factory method for creating a expression ezCC object. Set channel: 0-15, value: 0-127, onset: time in beats."
    fun static ezCC expression(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 11, value, onset);
        return c;
    }

    @doc "Static factory method for creating a pan ezCC object. Set channel: 0-15, value: 0-127 (64=center), onset: time in beats."
    fun static ezCC pan(int channel, int value, float onset)
    {
        ezCC c(0xB, channel, 10, value, onset);
        return c;
    }

    @doc "Static factory method for creating a pitch bend ezCC object. Set channel: 0-15, value: 0-16383 (14-bit, 8192=center), onset: time in beats. Converts to data1 LSB, data2 MSB."
    fun static ezCC pitchBend(int channel, int value, float onset)
    {
        if (value < 0) 0 => value;
        if (value > 16383) 16383 => value;
        (value & 0x7F) => int data1;
        ((value >> 7) & 0x7F) => int data2;
        ezCC c(0xE, channel, data1, data2, onset);
        return c;
    }

    @doc "Static factory method for creating a polyphonic aftertouch ezCC object. Set channel: 0-15, noteNumber: 0-127, pressure: 0-127, onset: time in beats."
    fun static ezCC aftertouch(int channel, int noteNumber, int pressure, float onset)
    {
        ezCC c(0xA, channel, noteNumber, pressure, onset);
        return c;
    }

    @doc "Static factory method for creating a channel pressure ezCC object. Set channel: 0-15, pressure: 0-127, onset: time in beats."
    fun static ezCC channelPressure(int channel, int pressure, float onset)
    {
        ezCC c(0xD, channel, pressure, 0, onset);
        return c;
    }

    @doc "Return the command byte: 11=CC, 10=aftertouch, 13=channel pressure, 14=pitch bend."
    fun int command()
    {
        return _command;
    }

    @doc "Set the command byte: 11=CC, 10=aftertouch, 13=channel pressure, 14=pitch bend."
    fun void command(int command)
    {
        command => _command;
    }

    @doc "Return the channel: 0-15."
    fun int channel()
    {
        return _channel;
    }

    @doc "Set the channel: 0-15."
    fun void channel(int channel)
    {
        channel => _channel;
    }

    @doc "Return the first data byte: 0-127."
    fun int data1()
    {
        return _data1;
    }

    @doc "Set the first data byte: 0-127."
    fun void data1(int data1)
    {
        data1 => _data1;
    }

    @doc "Return the second data byte: 0-127."
    fun int data2()
    {
        return _data2;
    }

    @doc "Set the second data byte: 0-127."
    fun void data2(int data2)
    {
        data2 => _data2;
    }

    @doc "Return the onset time in beats."
    fun float onset()
    {
        return _onset;
    }

    @doc "Set the onset time in beats."
    fun void onset(float onset)
    {
        onset => _onset;
    }

    @doc "True if command is Control Change (11)."
    fun int isCC()
    {
        return _isCC;
    }

    @doc "True if command is Pitch Bend (14)."
    fun int isPitchBend()
    {
        return _isPitchBend;
    }

    @doc "True if command is Polyphonic Aftertouch (10)."
    fun int isAftertouch()
    {
        return _isAftertouch;
    }

    @doc "True if command is Channel Pressure (13)."
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
