// This program is to demoonstrate the workings of the scrollbar class
// works fine, but,
// surprisingly, in Linux, nothing gets shown if fonts are
// not embedded in the textbox

package {
  import flash.display.*;
  import flash.text.*;
  import flash.events.*;
  import flash.utils.*;

  // Demonstrates the use of the ScrollBar class
  public class ScrollBarDemo extends Sprite {
      FontEmbedder;
    public function ScrollBarDemo () {
      // Create a TextField
      var inputfield:TextField = new TextField();
      inputfield.embedFonts = true;  
      // Use two variations of Verdana (normal, and bold)
      //inputfield.htmlText = "<FONT FACE='TIMES'>1</FONT>";
      //inputfield.htmlText += "1 <BR> 2 <br> 3 <br> 45 <br> 5 <br> 6 <br> 7 <br> 8 <br> 9";
      //inputfield.htmlText += "</FONT>";

      inputfield.text = "1\n3\n4\n5\n6\n7\n8\n9";
      
      // Seed the text field with some initial content
      inputfield.height = 50;
      inputfield.width  = 100;
      inputfield.border     = true;
      inputfield.background = true;
      inputfield.type = TextFieldType.INPUT;
      inputfield.antiAliasType = AntiAliasType.ADVANCED;
      inputfield.multiline = true;
      addChild(inputfield);

      // Create a scrollbar, and associate it with the TextField
      var scrollbar:ScrollBar = new ScrollBar(inputfield);
      addChild(scrollbar);
    }
  }
}