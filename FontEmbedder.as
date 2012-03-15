package {
  // Embeds the fonts for this application
  public class FontEmbedder {
    // Forward slashes are required, but case doesn't matter.
    [Embed(source="./fonts/TIMES.TTF", 
           fontFamily="TIMES")]
    private var TIMES:Class;

  }
}