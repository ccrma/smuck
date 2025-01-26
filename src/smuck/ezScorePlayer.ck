@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck", "ezScore.ck", "ezNoteEvent.ck", "ezDefaultInst.ck", "ezInstrument.ck"}

public class ezScorePlayer
{
    // public member variables
    ezScore score;
    ezPart parts[];
    ezInstrument instruments[];
    Gain previewGain => dac;
    
    // private member variables

    // Settable variables
    false => int _logPlayback;
    false => int _loop;
    1 => float _rate;
    float _bpm;

    // Internal variables
    2::ms => dur _tick;
    _tick => dur tatum;
    dur _playhead;
    dur previous_playhead;
    false => int _playing;

    dur start_of_score;
    dur end_of_score;
    Event tick_driver_end;

    ezDefaultInst previewInsts[];

    // Constructors
    fun ezScorePlayer() {}

    fun ezScorePlayer(ezScore s)
    {
        setScore(s);
    }

    // Public functions

    // Member variable get/set functions

    fun void tick(dur value)
    {
        value => _tick;
    }

    fun dur tick()
    {
        return _tick;
    }

    fun void loop(int loop)
    {
        loop => _loop;
    }

    fun int loop()
    {
        return _loop;
    }

    fun void rate(float value)
    {
        value => _rate;
    }

    fun float rate()
    {
        return _rate;
    }

    fun void bpm(float value)
    {
        value => _bpm;
        value / score.bpm() => _rate;
        setEnd(-1);
    }

    fun float bpm()
    {
        return _bpm;
    }

    fun void logPlayback(int value)
    {
        value => _logPlayback;
    }

    fun dur playhead()
    {
        return _playhead;
    }

    fun int isPlaying()
    {
        return _playing;
    }

    // Set the score to play
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
    fun void setInstrument(int partIndex, ezInstrument @ instrument)
    {
        instrument @=> instruments[partIndex];
    }

    // Set the instrument for all parts
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
    fun void preview()
    {
        setInstrument(previewInsts);
        play();
    }

    // Start playback
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
    fun void pause()
    {
        // <<< "ezScorePlayer: pause()" >>>;
        false => _playing;
        tick_driver_end => now;
        flushNotes();
    }

    // Stop playback
    fun void stop()
    {
        // <<< "ezScorePlayer: stop()" >>>;
        false => _playing;
        // <<<"sporking stop_listener">>>;
        spork ~ stop_listener();
    }

    // Set the end position of the score
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
    fun void pos(dur timePosition)
    {
        flushNotes();
        // <<<"moving playhead to position (ms):", timePosition/ms>>>;
        timePosition => _playhead;
        _playhead => previous_playhead;
    }

    // Set the playhead position by beat position
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
    fun void stop_listener()
    {
        tick_driver_end => now;
        pos(0);
    }

    // Kill all notes across all parts
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
    fun int playheadPassedTime(float timestamp)
    {
        return (Math.min(previous_playhead/ms, _playhead/ms) <= timestamp && timestamp < Math.max(previous_playhead/ms, _playhead/ms));
    }

    // Get all notes at the playhead position for a given part
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

        while((_playhead/ms - onset_ms)*direction < duration_ms) 
        {
            _tick => now;
        }

        instruments[partIndex].release_voice(voice_index);
    }
}

