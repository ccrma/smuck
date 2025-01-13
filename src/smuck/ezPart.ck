@import "ezMeasure.ck"

public class ezPart
{
    ezMeasure measures[0];
    int maxPolyphony;

    fun int numMeasures()
    {
        return measures.size();
    }

    fun void add_measure(ezMeasure measure)
    {
        measures << measure;
    }
}