@import "ezMeasure.ck"

public class ezPart
{
    ezMeasure measures[0];
    int maxPolyphony;

    fun int numMeasures()
    {
        return measures.size();
    }
}
