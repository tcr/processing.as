// a sample program that loads a program from a url and
// displays it in a textbox

package {
  import flash.display.*;
  import flash.events.*;
  import flash.net.*;
  import flash.text.TextField;

  // Demonstrates the code required to load external XML
  public class programLoader extends Sprite {

    FontEmbedder;

    // The variable to which the loaded XML will be assigned
    private var novel:String;
    // The object used to load the XML
    private var urlLoader:URLLoader;
      var greeting_txt:TextField = new TextField();
      
    // Constructor
    public function programLoader ( ) {
    
      var t:TextField = new TextField();
      t.embedFonts = true;  
      
      // Specify the text to display
      t.text = "Hello world";
      // Add the TextField object to the display list
      addChild(t);
      
          var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
        var valueStr:String = String(paramObj["linkToSource"]);

      // Specify the location of the external XML
      var urlRequest:URLRequest = new URLRequest(valueStr);
      // Create an object that can load external text data
      urlLoader = new URLLoader( );
      // Register to be notified when the XML finishes loading
      urlLoader.addEventListener(Event.COMPLETE, completeListener);
      // Load the XML
      urlLoader.load(urlRequest);

      greeting_txt.embedFonts = true;
      greeting_txt.text = "loading...";
      greeting_txt.x = 60;
      greeting_txt.y = 25;
      addChild(greeting_txt);  // Depth 0
      
    }

    // Method invoked automatically when the XML finishes loading
    private function completeListener(e:Event):void {
      // The string containing the loaded XML is assigned to the URLLoader
      // object's data variable (i.e., urlLoader.data). To create a new XML
      // instance from that loaded string, we pass it to the XML constructor
      novel = new String(urlLoader.data);
      trace(novel); // Display the loaded XML, now converted
                                   // to an XML object
                                   
                                   // Create a text message
      greeting_txt.text = str_replace("source code: " + novel + "end of source code","<br>","\n");
      //greeting_txt..htmlText = "source code: " + novel + "end of source code";
      
    }
    function str_replace(haystack:String, needle:String, replacement:String):String {
    	var temp:Array = haystack.split(needle);
    return temp.join(replacement);
}
  }
}