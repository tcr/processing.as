package processing.api
{
	import flash.external.ExternalInterface;

	dynamic public class Minim  {
		private var _type:*;
	
		public function Minim( theThisThing:* = null )
		{
			//ExternalInterface.call("printSomething", "minim created\n" ); //ddc
		}
		
		public function loadFile(theFileOrURL:String):AudioPlayer
		{
						
			//ExternalInterface.call("printSomething", "loading: " + theFileOrURL ); //ddc

			//ExternalInterface.call("printSomething", " last character: >" + theFileOrURL.substring(theFileOrURL.length-1,theFileOrURL.length) + "<" ); //ddc
			if (theFileOrURL.substring(theFileOrURL.length-1,theFileOrURL.length)=="/"){
			theFileOrURL = theFileOrURL.substring(0,theFileOrURL.length-1);
			}

			var lastPiece = theFileOrURL.substring(theFileOrURL.length-9,theFileOrURL.length);
			//ExternalInterface.call("printSomething", "last piece is: " + lastPiece ); //ddc
			if (lastPiece=="/download") {
				var firstPiece = theFileOrURL.substring(0,theFileOrURL.length-9);
				//ExternalInterface.call("printSomething", "first piece is: " + firstPiece ); //ddc
				theFileOrURL = 	firstPiece;
			}
			return new AudioPlayer(theFileOrURL);
		}
		
	}
}