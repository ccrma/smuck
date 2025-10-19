@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezDefaultInst.ck", "ezInstrument.ck"}

@doc "Class used for playing back ezScore objects. Users should set an ezScore object to be played, as well as ezInstrument objects specifying sound synthesis for each part. See https://chuck.stanford.edu/smuck/doc/walkthru.html for more information"
public class ezScorePlayer
{   
    // Public 
    // --------------------------------------------------------------------------
    @doc "(hidden)"
    ezScore _score;

    @doc "(hidden)"
    ezInstrument _instruments[];

    @doc "(hidden)"
    2::ms => dur _tick;

    @doc "(hidden)"
    float _playhead;

    @doc "(hidden)"
    float _startPos;

    @doc "(hidden)"
    float _endPos;

    @doc "(hidden)"
    false => int _playing;

    @doc "(hidden)"
    false => int _logPlayback;

    @doc "(hidden)"
    120.0 => float _bpm;

    @doc "(hidden)"
    1 => float _rate;

    @doc "(hidden)"
    false => int _loop;

    // Private
    // --------------------------------------------------------------------------
    @doc "(hidden)"
    _bpm * ( (_tick * _rate) / 1::minute) => float _tatum; // default of .004 beats per tick

    @doc "(hidden)"
    float _previous_playhead;

    @doc "(hidden)"
    Event tick_driver_end;

    @doc "(hidden)"
    ezDefaultInst previewInsts[];

    @doc "(hidden)"
    int _previewOn;

    // Constructors
    // --------------------------------------------------------------------------
    @doc "Default constructor, creates an empty ezScorePlayer"
    fun ezScorePlayer() {}

    @doc "Create an ezScorePlayer from an ezScore object"
    fun ezScorePlayer(ezScore s)
    {
        score(s);
    }

    @doc "Create an ezScorePlayer from an ezScore object and an ezInstrument array"
    fun ezScorePlayer(ezScore s, ezInstrument insts[])
    {
        score(s);
        instruments(insts);
    }

    // Public functions
    // --------------------------------------------------------------------------

    // Score initialization
    // --------------------------------------------------------------------------
    @doc "Set the ezScore object to be played back. If the player is currently playing, it will be stopped first."
    fun ezScore score(ezScore s)
    {
        if (_playing) stop();
        
        s @=> _score;
        s.bpm() => _bpm;

        // create instruments
        new ezInstrument[_score.parts().size()] @=> _instruments;

        // create preview instrument
        new ezDefaultInst[_score.parts().size()] @=> previewInsts;
        for(int i; i < _score.parts().size(); i++)
        {
            ezDefaultInst tempInst;
            tempInst @=> previewInsts[i];
        }

        // remember the end position of the score
        endPos(_score.beats());

        return _score;
    }

    @doc "Get the ezScore object associated with this ezScorePlayer."
    fun ezScore score()
    {
        return _score;
    }

    // Instrument assignment
    // --------------------------------------------------------------------------
    @doc "Get the ezInstrument objects associated with this ezScorePlayer, as an ezInstrument array."
    fun ezInstrument[] instruments()
    {
        return _instruments;
    }

    @doc "Set the ezInstrument objects to be used for all parts, using an ezInstrument array. The array must be the same size as the number of parts in the score."
    fun ezInstrument[] instruments(ezInstrument @ insts[])
    {
        if (insts.size() != _score.parts().size())
        {
            <<< "ezScorePlayer: setInstruments() - provided instrument array size does not match the number of parts. input size:", insts.size(), "| parts size:", _score.parts().size() >>>;
            return _instruments;
        }

        for(int i; i < insts.size(); i++)
        {
            instruments(i, insts[i]);
        }

        return _instruments;
    }

    @doc "Set the ezInstrument object to be used for a given part"
    fun ezInstrument instruments(int partIndex, ezInstrument @ instrument)
    {
        instrument @=> _instruments[partIndex];
        if(_previewOn)
        {
            disconnectPreview();
        }
        return _instruments[partIndex];
    }

    @doc "(hidden)"
    fun ezInstrument instruments(ezInstrument @ instrument)
    {
        // instrument @=> _instruments[0];
        instruments(0, instrument);
        return _instruments[0];
    }

    // Preview the score by playing back using default instruments
    @doc "Preview the score by playing back using default instruments. Can be used to quickly preview the score without having to set instruments for each part."
    fun void preview()
    {
        true => _previewOn;
        previewInsts @=> _instruments;

        // Connect preview instruments to dac
        for(int i; i < _score.parts().size(); i++)
        {
            previewInsts[i] => dac;
        }
        play();
    }

    // Playback control
    // --------------------------------------------------------------------------

    @doc "Start playback of the score."
    fun void play()
    {
        // <<< "ezScorePlayer: play()" >>>;
        if (!_playing)
        {
            true => _playing;
            // <<<"sporking tickDriver">>>;
            spork ~ tickDriver();
        }
    }

    @doc "Pause playback of the score."
    fun void pause()
    {
        // <<< "ezScorePlayer: pause()" >>>;
        false => _playing;
        tick_driver_end => now;
        flushNotes();
    }

    @doc "Stop playback of the score."
    fun void stop()
    {
        pause();
        pos(_startPos);
    }

    @doc "Get the start position of the score in beats."
    fun float startPos()
    {
        return _startPos;
    }

    @doc "Set the start position of the score in beats."
    fun float startPos(float beat)
    {
        if(beat > _endPos)
        {
            <<< "ezScorePlayer: startPos() - provided beat is after the end position. beat:", beat, "| playback end position:", _endPos, "| reverting to start position: ", _startPos >>>;
            return _startPos;
        }

        if(_playhead < beat)
        {
            beat => _previous_playhead;
            beat => _playhead;
        }

        beat => _startPos;
        return _startPos;
    }

    @doc "Set the start position of the score in absolute time."
    fun dur startPos(dur timePosition)
    {
         _bpm * (timePosition / minute) => float beatPosition;
        startPos(beatPosition);
        return timePosition;
    }

    @doc "Get the end position of the score in beats."
    fun float endPos()
    {
        return _endPos;
    }

    @doc "Set the end position of the score in beats. If the end position is set to -1, the end position will automatically be set to the score's end position."
    fun float endPos(float beat)
    {
        if(beat < _startPos)
        {
            <<< "ezScorePlayer: endPos() - provided beat is before the start position. beat:", beat, "| playback start position:", _startPos, "| reverting to end position: ", _endPos >>>;
            return _endPos;
        }
        if (beat > _score.beats())
        {
            <<< "ezScorePlayer: endPos() - provided beat is after the score end. beat:", beat, "| playback end position:", _score.beats(), "| reverting to end position: ", _endPos >>>;
            return _endPos;
        }

        beat => _endPos;
        return _endPos;
    }

    @doc "Set the end position of the score in absolute time."
    fun dur endPos(dur timePosition)
    {
         _bpm * (timePosition / minute) => float beatPosition;
        endPos(beatPosition);
        return timePosition;
    }

    @doc "Get the playhead position in beats."
    fun float pos()
    {
        return _playhead;
    }

    @doc "Set the playhead position by beat position."
    fun float pos(float beatPosition)
    {
        if (beatPosition >= _startPos && beatPosition <= _endPos)
        {
            flushNotes();
            // <<<"moving playhead to position (beats):", beatPosition>>>;
            beatPosition => _playhead;
            _playhead => _previous_playhead;
        }
        else
        {
            <<< "ezScorePlayer: pos() - provided beat position is out of bounds. beat:", beatPosition, "| playback start position:", _startPos, "| playback end position:", _endPos >>>;
        }
        return _playhead;
    }

    @doc "Set the playhead position by absolute time."
    fun dur pos(dur timePosition)
    {
        _bpm * (timePosition / minute) => float beatPosition;
        pos(beatPosition);
        return timePosition;
    }


    @doc "Set the tick duration for the ezScorePlayer. This represents the update rate of the player's internal clock."
    fun dur tick(dur value)
    {
        value => _tick;
        return _tick;
    }

    @doc "Get the tick update rate for the ezScorePlayer. This represents the update rate of the player's internal clock."
    fun dur tick()
    {
        return _tick;
    }

    @doc "Set the tempo for the ezScorePlayer in BPM (beats per minute). Can be changed dynamically during playback."
    fun float bpm(float value)
    {
        value => _bpm;
        value / _score.bpm() => _rate;
        // endPos(_score.beats());
        return _bpm;
    }

    @doc "Get the tempo for the ezScorePlayer in BPM (beats per minute). Can be changed dynamically during playback."
    fun float bpm()
    {
        return _bpm;
    }

    @doc "Set the playback rate for the ezScorePlayer. Defalut value of 1.0. Used to speed up or slow down playback. Negative values play the score in reverse."
    fun float rate(float value)
    {
        value => _rate;
        return _rate;
    }

    @doc "Get the playback rate for the ezScorePlayer. Defalut value of 1.0. Used to speed up or slow down playback. Negative values play the score in reverse."
    fun float rate()
    {
        return _rate;
    }

    @doc "Set the loop mode. If true, the player will loop back to the start of the score when it reaches the end."
    fun int loop(int loop)
    {
        loop => _loop;
        return _loop;
    }

    @doc "Get the loop mode. If true, the player will loop back to the start of the score when it reaches the end."
    fun int loop()
    {
        return _loop;
    }

    @doc "Toggle on/off logging of playback events. If true, current note events are logged to the console as they are played."
    fun int logPlayback(int value)
    {
        value => _logPlayback;
        return _logPlayback;
    }

    @doc "Get the current playback state for the ezScorePlayer. If true, the player is currently playing."
    fun int isPlaying()
    {
        return _playing;
    }


    // Private functions
    // --------------------------------------------------------------------------
    
    // Tick driver to advance time
    @doc "(hidden)"
    fun void tickDriver()
    {
        while (_playing)
        {
            if (_playhead > _endPos)
            {
                if (_loop) pos(_startPos);
                else stop();
            }
            if (_playhead < _startPos)
            {
                if (_loop) pos(_endPos);
                else stop();
            }
            
            for(int i; i < _score.parts().size(); i++)
            {
                getNotesAtPlayhead(i);
            }
            _bpm * ( (_tick * _rate) / 1::minute) => _tatum; 
            _playhead => _previous_playhead;
            _tatum +=> _playhead;

            _tick => now;
        }
        tick_driver_end.signal();
    }

    // Kill all notes across all parts
    @doc "(hidden)"
    fun void flushNotes()
    {
        // <<<"flushing notes">>>;
        for(int part; part < _score.parts().size(); part++)
        {
            for(int voice; voice < _instruments[part]._numVoices; voice++)
            {
                // <<<"releasing voice", voice, "for part", part>>>;
                ezNote dummyNote;
                _instruments[part].noteOff(dummyNote, voice);
                _instruments[part].release_voice(voice);
            }
        }
    }

    // Check if the playhead has passed a given time position
    @doc "(hidden)"
    fun int playheadPassedTime(float timestamp)
    {
        return (Math.min(_previous_playhead, _playhead) <= timestamp && timestamp < Math.max(_previous_playhead, _playhead));
    }

    // Get all notes at the playhead position for a given part
    @doc "(hidden)"
    fun void getNotesAtPlayhead(int partIndex)
    {
        _score.parts()[partIndex] @=> ezPart part;
        ezNote currentNotes[0];
        float measure_onset;

        for(int i; i < part.measures().size(); i++)
        {
            part.measures()[i] @=> ezMeasure measure;

            for(int j; j < measure.notes().size(); j++)
            {

                measure.notes()[j] @=> ezNote note;
                measure_onset + note.onset() => float note_onset;
                
                if(playheadPassedTime(note_onset))
                {
                    currentNotes << note;
                }
            }
            measure.beats() +=> measure_onset;
        }
        if(currentNotes.size() > 0)
        {
            for(int i; i < currentNotes.size(); i++)
            {
                // <<<"sporking note", currentNotes[i].pitch(), "on voice", i, "for part", partIndex>>>;
                spork ~ playNote(partIndex, currentNotes[i]);
            }
        }
    }

    @doc "(hidden)"
    fun void playNote(int partIndex, ezNote note)
    {
        int voice_index;

        if (!note.isRest())
        {
            _instruments[partIndex].allocate_voice(note) => voice_index;
            _instruments[partIndex].noteOn(note, voice_index);

            if(_logPlayback)
            {
                chout <= "playing note " <= note.pitch() <= " on voice " <= voice_index <= " for part " <= partIndex <= " at playhead position " <= _playhead <= ", at beat onset " <= note.onset() <= " for " <= note.beats() <= " beats, with velocity " <= note.velocity() <= IO.newline();
            }
        }

        _playhead => float onset;
        Math.sgn(_rate) => float direction;
        (_playhead - onset)*direction => float elapsed_beats;

        while(elapsed_beats >= 0 && elapsed_beats < note.beats() && _playing)
        {
            // <<<"playing">>>;
            _tick => now;
            (_playhead - onset)*direction => elapsed_beats;
        }

        if (!note.isRest())
        {
            // <<<"stopping">>>;
            _instruments[partIndex].noteOff(note, voice_index);
            _instruments[partIndex].release_voice(voice_index); // NOTE (2/27): this was making noteOffs not work properly, as next noteOn would immediately happen and cut off the noteOff
        }
    }

    @doc "(hidden)" 
    fun void disconnectPreview()
    {
        false => _previewOn;
        for(int i; i < _score.parts().size(); i++)
        {
            previewInsts[i] =< dac;
        }
    }
}

