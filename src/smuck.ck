@import {"smuck/ezNote.ck", "smuck/ezMeasure.ck", "smuck/ezPart.ck", "smuck/ezScore.ck"}
@import {"smuck/ezInstrument.ck", "smuck/ezScorePlayer.ck"}
@import {"smuck/ezMidiInst.ck", "smuck/ezOscInst.ck", "smuck/ezExternalInst.ck"}
@import {"smuck/Smuckish.ck"}

// should be explicitly imported by user
// @import {"smuck/ezFluidInst.ck"}

@doc "A collection of SMucK-related high-level functions."
public class Smuck
{
    @doc "retrieve smuck version as a string"
    fun static string version()
    {
        return "0.1.3";
    }

    @doc "convert a MIDI note number to a pitch name"
    fun static string mid2str( float note )
    {
        return smUtils.mid2str( note );
    }

    @doc "Convert a pitch name to a MIDI note number"
    fun static int str2mid( string note )
    {
        return smUtils.str2mid( note );
    }
}
