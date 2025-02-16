@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezNoteEvent.ck", "ezDefaultInst.ck", "ezInstrument.ck"}

public class ezScorePlayer
{
    // public member variables
    @doc "The ezScore object to be played back"
    ezScore score;

    @doc "The ezPart objects in the score. Set automatically when a score is set for the player."
    ezPart parts[];

    @doc "The ezInstrument objects to be used in playback. Need to set manually for each part."
    ezInstrument instruments[];

    @doc "Gain object to control volume of the playback in preview mode"
    Gain previewGain => dac;
    
    // private member variables
    // Settable variables
    @doc "(hidden)"
    false => int _logPlayback;

    @doc "(hidden)"
    false => int _loop;

    @doc "(hidden)"
    1 => float _rate;

    @doc "(hidden)"
    float _bpm;

    // Internal variables
    @doc "(hidden)"
    2::ms => dur _tick;

    @doc "(hidden)"
    _tick => dur tatum;

    @doc "(hidden)"
    dur _playhead;

    @doc "(hidden)"
    dur previous_playhead;

    @doc "(hidden)"
    false => int _playing;

    @doc "(hidden)"
    dur start_of_score;

    @doc "(hidden)"
    dur end_of_score;

    @doc "(hidden)"
    Event tick_driver_end;

    @doc "(hidden)"
    ezDefaultInst previewInsts[];

    // Constructors
    // --------------------------------------------------------------------------
    @doc "Default constructor, creates an empty ezScorePlayer"
    fun ezScorePlayer() {}

    @doc "Create an ezScorePlayer from an ezScore object"
    fun ezScorePlayer(ezScore s)
    {
        setScore(s);
    }

    // Public functions

    // Member variable get/set functions
    // --------------------------------------------------------------------------
    @doc "Set the tick duration for the ezScorePlayer. This represents the update rate of the player's internal clock."
    fun void tick(dur value)
    {
        value => _tick;
    }

    @doc "Get the tick update rate for the ezScorePlayer. This represents the update rate of the player's internal clock."
    fun dur tick()
    {
        return _tick;
    }

    @doc "Set the loop mode. If true, the player will loop back to the start of the score when it reaches the end."
    fun void loop(int loop)
    {
        loop => _loop;
    }

    @doc "Get the loop mode. If true, the player will loop back to the start of the score when it reaches the end."
    fun int loop()
    {
        return _loop;
    }

    @doc "Set the playback rate for the ezScorePlayer. Defalut value of 1.0. Used to speed up or slow down playback. Negative values play the score in reverse."
    fun void rate(float value)
    {
        value => _rate;
    }

    @doc "Get the playback rate for the ezScorePlayer. Defalut value of 1.0. Used to speed up or slow down playback. Negative values play the score in reverse."
    fun float rate()
    {
        return _rate;
    }

    @doc "Set the tempo for the ezScorePlayer in BPM (beats per minute). Can be changed dynamically during playback."
    fun void bpm(float value)
    {
        value => _bpm;
        value / score.bpm() => _rate;
        setEnd(-1);
    }

    @doc "Get the tempo for the ezScorePlayer in BPM (beats per minute). Can be changed dynamically during playback."
    fun float bpm()
    {
        return _bpm;
    }

    @doc "Toggle on/off logging of playback events. If true, current note events are logged to the console as they are played."
    fun void logPlayback(int value)
    {
        value => _logPlayback;
    }

    @doc "Get the current playhead position for the ezScorePlayer. This represents the current position in the score in ms."
    fun dur playhead()
    {
        return _playhead;
    }

    @doc "Get the current playback state for the ezScorePlayer. If true, the player is currently playing."
    fun int isPlaying()
    {
        return _playing;
    }

    // Set the score to play
    // --------------------------------------------------------------------------
    @doc "Set the ezScore object to be played back. If the player is currently playing, it will be stopped first."
    fun void setScore(ezScore s)
    {
        if (_playing) stop();
        
        s @=> score;
        s.parts @=> parts;
        s.bpm() => _bpm;

        // create instruments
        new ezInstrument[score.numParts()] @=> instruments;

        // create preview instrument
        new ezDefaultInst[score.numParts()] @=> previewInsts;
        for(int i; i < score.numParts(); i++)
        {
            ezDefaultInst tempInst;
            tempInst @=> previewInsts[i];
        }

        // remember the end position of the score
        setEnd(-1);
    }

    // Set the instrument for a part
    @doc "Set the ezInstrument object to be used for a given part"
    fun void setInstrument(int partIndex, ezInstrument @ instrument)
    {
        instrument @=> instruments[partIndex];
    }

    // Set the instrument for all parts
    @doc "Set the ezInstrument objects to be used for all parts. The array must be the same size as the number of parts in the score."
    fun void setInstrument(ezInstrument @ insts[])
    {
        if (insts.size() != parts.size())
        {
            <<< "ezScorePlayer: setInstrument() - provided instrument array size does not match the number of parts. size:", insts.size(), "| parts size:", parts.size() >>>;
            return;
        }

        for(int i; i < insts.size(); i++)
        {
            setInstrument(i, insts[i]);
        }
    }

    // Preview the score by playing back using default instruments
    @doc "Preview the score by playing back using default instruments. Can be used to quickly preview the score without having to set instruments for each part."
    fun void preview()
    {
        setInstrument(previewInsts);
        for(int i; i < score.numParts(); i++)
        {
            previewInsts[i] => dac;
        }
        play();
    }

    // Start playback
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

    // Pause playback
    // --------------------------------------------------------------------------
    @doc "Pause playback of the score."
    fun void pause()
    {
        // <<< "ezScorePlayer: pause()" >>>;
        false => _playing;
        tick_driver_end => now;
        flushNotes();
    }

    // Stop playback
    // --------------------------------------------------------------------------
    @doc "Stop playback of the score."
    fun void stop()
    {
        // <<< "ezScorePlayer: stop()" >>>;
        false => _playing;
        // <<<"sporking stop_listener">>>;
        spork ~ stop_listener();
    }

    // Set the end position of the score
    // --------------------------------------------------------------------------
    @doc "Set the end position of the score in beats. If the end position is set to -1, the end position will automatically be set to the score's end position."
    fun void setEnd(float beat)
    {
        if (beat > score.scoreEnd())
        {
            <<< "ezScorePlayer: setScoreEnd() - provided beat is after the score end. beat:", beat, "| score end:", score.scoreEnd() >>>;
            return;
        }
        if (beat == -1)
        {
            score.scoreEnd() => beat;
        }
        (beat * 60000 / score.bpm())::ms => end_of_score;     // convert to dur, so playhead can be compared to it
    }

    // Set the playhead position by absolute time
    // --------------------------------------------------------------------------
    @doc "Set the playhead position by absolute time in ms."
    fun void pos(dur timePosition)
    {
        flushNotes();
        // <<<"moving playhead to position (ms):", timePosition/ms>>>;
        timePosition => _playhead;
        _playhead => previous_playhead;
    }

    // Set the playhead position by beat position
    // --------------------------------------------------------------------------
    @doc "Set the playhead position by beat position."
    fun void pos(float beatPosition)
    {
        flushNotes();
        // <<<"moving playhead to position (beats):", beatPosition>>>;
        60000 / _bpm => float ms_per_beat;
        ms_per_beat * (4 / score._time_sig_denominator) => ms_per_beat;
        (beatPosition * ms_per_beat)::ms => _playhead;
        _playhead => previous_playhead;
    }

    // Set the playhead position by measure and beat position
    @doc "(hidden)"
    fun void pos(int measures, float beats) // CHANGE THIS TO USE ACTUAL MEASURES AND BEATS
    {
        flushNotes();
        // <<<"moving playhead to position (measure, beats):", measures, beats>>>;
        60000 / _bpm => float ms_per_beat;
        (measures * (ms_per_beat * score._time_sig_numerator * (4 / score._time_sig_denominator)) + beats * ms_per_beat)::ms => _playhead;
        _playhead => previous_playhead;
    }

    // Private functions

    // Tick driver to advance time
    @doc "(hidden)"
    fun void tickDriver()
    {
        while (_playing)
        {
            if (_playhead > end_of_score)
            {
                if (_loop) pos(0);
                else stop();
            }
            if (_playhead < start_of_score)
            {
                if (_loop) pos(end_of_score);
                else stop();
            }
            
            for(int i; i < parts.size(); i++)
            {
                getNotesAtPlayhead(i);
            }

            _tick * _rate => tatum;
            _playhead => previous_playhead;
            tatum +=> _playhead;

            _tick => now;
        }
        tick_driver_end.signal();
    }

    // Stop listener to reset playhead position when playback stops, preventing hanging notes
    @doc "(hidden)"
    fun void stop_listener()
    {
        tick_driver_end => now;
        pos(0);
    }

    // Kill all notes across all parts
    @doc "(hidden)"
    fun void flushNotes()
    {
        // <<<"flushing notes">>>;
        for(int part; part < parts.size(); part++)
        {
            for(int voice; voice < instruments[part]._numVoices; voice++)
            {
                // <<<"releasing voice", voice, "for part", part>>>;
                instruments[part].release_voice(voice);
            }
        }
    }

    // Check if the playhead has passed a given time position
    @doc "(hidden)"
    fun int playheadPassedTime(float timestamp)
    {
        return (Math.min(previous_playhead/ms, _playhead/ms) <= timestamp && timestamp < Math.max(previous_playhead/ms, _playhead/ms));
    }

    // Get all notes at the playhead position for a given part
    @doc "(hidden)"
    fun void getNotesAtPlayhead(int partIndex)
    {
        parts[partIndex] @=> ezPart thePart;
        60000 / score.bpm() => float ms_per_beat;

        ezNote currentNotes[0];

        for(int i; i < thePart.measures.size(); i++)
        {
            thePart.measures[i] @=> ezMeasure theMeasure;

            for(int j; j < theMeasure.notes.size(); j++)
            {
                theMeasure.onset() * ms_per_beat => float theMeasure_onset_ms;
                theMeasure.notes[j] @=> ezNote theNote;
                theMeasure_onset_ms + theNote.onset() * ms_per_beat => float theNote_onset_ms;
                
                if(playheadPassedTime(theNote_onset_ms))
                {
                    currentNotes << theNote;
                }
            }
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
    fun void playNote(int partIndex, ezNote theNote)
    {
        instruments[partIndex].allocate_voice(theNote) => int voice_index;
        instruments[partIndex].noteOn(theNote, voice_index);

        if(_logPlayback)
        {
            chout <= "playing note " <= theNote.pitch() <= " on voice " <= voice_index <= " for part " <= partIndex <= " at time " <= _playhead/ms <= "ms," <= " at beat onset " <= theNote.onset() <= " for " <= theNote.beats() <= " beats, with velocity " <= theNote.velocity() <= IO.newline();
        }

        _playhead/ms => float onset_ms;
        60000 / score.bpm() => float ms_per_beat;
        theNote.beats() * ms_per_beat => float duration_ms;
        Math.sgn(_rate) => float direction;

        (_playhead/ms - onset_ms)*direction => float elapsed_ms;

        while(elapsed_ms >= 0 && elapsed_ms < duration_ms)
        {
            _tick => now;
            (_playhead/ms - onset_ms)*direction => elapsed_ms;
        }

        instruments[partIndex].release_voice(voice_index);
    }
}

