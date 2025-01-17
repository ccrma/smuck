@import "ezMeasure.ck"

public class ezPart
{
    ezMeasure measures[0];
    int maxPolyphony;

    fun int numMeasures()
    {
        return measures.size();
    }

    fun void append_measure(ezMeasure @ measure)
    {
        if(measures.size() == 0)
        {
            0 => measure.onset;
        }
        else
        {
            measures[-1].length + measures[-1].onset => measure.onset;
        }
        measures << measure;
    }
}