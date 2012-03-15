// This very very basic program is to make sure that string
// visualisation works fine. The reason for this test is that
// surprisingly, in Linux, nothing gets shown if fonts are
// not embedded

package {
  import flash.display.*;
  import flash.text.*;

  // This class demonstrates how to format text using embedded fonts.
  // The fonts, themselves, are embedded in the class FontEmbedder.
  public class HelloWorld extends Sprite {
    // Make a reference to the class that embeds the fonts for this 
    // application. This reference causes the class and, by extension, its 
    // fonts to be compiled into the .swf file.
    FontEmbedder;

    public function HelloWorld () {
      // Create a text field
      var t:TextField = new TextField();
      
      // Tell ActionScript to render this text field using embedded fonts
      t.embedFonts = true; 
      //t.autoSize = "true";  
      t.autoSize    = TextFieldAutoSize.LEFT;
t.wordWrap    = true;
t.selectable  = true;
t.multiline   = true;
t.border              = true;
t.width             = 200;

      // Use two variations of Verdana (normal, and bold)
      t.htmlText = "<FONT FACE='TIMES' SIZE='30' >Hello world</FONT>";

      // Enable FlashType (i.e., Saffron) text rendering
      t.antiAliasType = AntiAliasType.ADVANCED;

      // Add the text field to the display list
      addChild(t);
    }
  }
}