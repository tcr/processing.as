

package {
  import flash.display.*;
  import flash.text.*;

  // This class demonstrates how to format text using embedded fonts.
  // The fonts, themselves, are embedded in the class FontEmbedder.
  public class parameterPassing extends Sprite {
    // Make a reference to the class that embeds the fonts for this 
    // application. This reference causes the class and, by extension, its 
    // fonts to be compiled into the .swf file.
    FontEmbedder;

    public function parameterPassing() {
      // Create a text field
      var t:TextField = new TextField();
      
      // Tell ActionScript to render this text field using embedded fonts
      t.embedFonts = true;  
      
      var format2_fmt:TextFormat = new TextFormat();
format2_fmt.font = "TIMES";
format2_fmt.size = 32;

t.autoSize    = TextFieldAutoSize.LEFT;
t.wordWrap    = true;
t.selectable  = true;
t.multiline   = true;
t.border              = true;
t.width             = 200;

//t.autoSize= "true";

t.setTextFormat(format2_fmt);
      
      // Use two variations of Verdana (normal, and bold)

t.htmlText = "<FONT FACE='TIMES' SIZE='30' >";

t.appendText("params:" + "\n");
try {
    var keyStr:String;
    var valueStr:String;
    var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
    for (keyStr in paramObj) {
        valueStr = String(paramObj[keyStr]);
        t.appendText("\t" + keyStr + "\t" + valueStr + "\n");
    }
} catch (error:Error) {
    t.appendText("error");
}
      // Enable FlashType (i.e., Saffron) text rendering
      //t.antiAliasType = AntiAliasType.ADVANCED;

      // Add the text field to the display list
      addChild(t);
    }
  }
}