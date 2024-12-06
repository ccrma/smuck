@import {"ezNote.ck", "ezMeasure.ck", "ezPart.ck"}

public class ezScore
{
    ezPart parts[0];

    4 => int time_sig_numerator;
    4 => int time_sig_denominator;
    128 => float bpm;

    fun ezScore(string filename)
    {
        if(filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
    }

    fun ezScore(string filename, float newBpm)
    {
        newBpm => bpm;

        if(filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
    }

    fun ezScore(string filename, float newBpm, int timeSig[])
    {
        newBpm => bpm;

        if(timeSig.size() != 2)
        {
            <<<"timeSig must be an array of size 2">>>;
        }   
        else
        {
            timeSig[0] => time_sig_numerator;
            timeSig[1] => time_sig_denominator;
        }

        if(filename.substring(filename.length() - 4,4) == ".mid")
        {
            importMIDI(filename);
        }
    }

    fun void setTempo(float newBpm)
    {
        newBpm => bpm;
    }

    fun void setTimeSig(int numerator, int denominator)
    {
        numerator => time_sig_numerator;
        denominator => time_sig_denominator;
    }

    fun void importMIDI(string filename) {
        MidiFileIn min;
        MidiMsg msg;
        
        if( !min.open(filename) ) me.exit();
        // min.beatsPerMinute() => bpm;

        for (0 => int track; track < min.numTracks(); track++) {
            ezPart part;
            0 => int currPolyCount;

            float note_on_time[128];    // stores the note onset times (ms) for Note-On events, indexed by pitch
            int note_index[128];       // stores the latest index a note was added to
            
            0 => float accumulated_time_ms;

            60000 / bpm => float ms_per_beat;
            time_sig_numerator * ms_per_beat => float measure_length_ms;
            
            ezMeasure measure1;
            part.measures << measure1;
            
            while (min.read(msg, track)) {
                // update the accumulated time for the measure to present moment
                accumulated_time_ms + msg.when/ms => accumulated_time_ms;

                // if (accumulated_time_ms > measure_length_ms) {
                //     ezMeasure new_measure;
                //     part.measures << new_measure;
                //     0 => accumulated_time_ms;       // accumulated time is reset to 0 with each new measure
                // }

                part.measures[-1] @=> ezMeasure current_measure;

                // Note On
                if ((msg.data1 & 0xF0) == 0x90 && msg.data2 > 0 && msg.data3 > 0) {
                    // <<< "NOTE ON!!", msg.data2 >>>;
                    msg.data2 => int pitch;
                    msg.data3 => int velocity;

                    // 1. Update the note onset time for received pitch
                    accumulated_time_ms => note_on_time[pitch];

                    // 2. Add temporary note (undetermined duration) to the measure
                    accumulated_time_ms / ms_per_beat => float onset_time_beats;
                    ezNote tempNote(onset_time_beats, 0, pitch, velocity);           // 0 as temporary duration, will update when the note ends
                    current_measure.notes << tempNote;
                    // <<<"Current # of measures:", part.measures.size()>>>;
                    // <<<"# of notes in the measure: ", current_measure.notes.size()>>>;
                    // 3. Store the index in the measure for that pitch, so we can find it's associated note when we need to update duration
                    current_measure.notes.size() - 1 => note_index[pitch];

                    // increase polyphony count by 1
                    1 +=> currPolyCount;

                    // update max polyphony
                    if (part.maxPolyphony < currPolyCount)
                    {
                        currPolyCount => part.maxPolyphony;
                    }
                }

                // Note Off
                if ((msg.data1 & 0xF0) == 0x80 && msg.data2 > 0 && msg.data3 > 0) {
                    // <<< "NOTE OFF", msg.data2 >>>;
                    msg.data2 => int pitch;
                    msg.data3 => int velocity;

                    // 1. Find note duration for given pitch
                    (accumulated_time_ms - note_on_time[pitch]) / ms_per_beat => float note_duration_beats;

                    // 2. Update the duration of the relevant note
                    // <<< "note index at pitch", note_index[pitch] >>>;
                    // <<<"Current # of measures:", part.measures.size()>>>;
                    // <<<"# of notes in the measure (after noteoff): ", current_measure.notes.size()>>>;
                    note_duration_beats => current_measure.notes[note_index[pitch]].beats;

                    // decrease polyphony count by 1;
                    1 -=> currPolyCount;
                }
            }
            // parts << part;
            if(part.maxPolyphony > 0)
            {
                parts << part;
                //<<< "part added!" >>>;
            }

        }
    }
}