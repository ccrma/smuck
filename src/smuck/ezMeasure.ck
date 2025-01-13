@import "ezNote.ck"

public class ezMeasure
{
    ezNote notes[0];

    fun int numNotes()
    {
        return notes.size();
    }

    fun void add_note(ezNote note)
    {
        notes << note;
    }
}