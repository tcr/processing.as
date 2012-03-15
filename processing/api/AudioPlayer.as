package processing.api
{
	import flash.external.ExternalInterface;

	dynamic public class AudioPlayer  {
	
		public function AudioPlayer( theFileOrURL:String )
		{
			    //ExternalInterface.call("printSomething", "calling tellSoundCloudWidgetToLoadURL\n " ); //ddc
				ExternalInterface.call("tellSoundCloudWidgetToLoadURL", theFileOrURL ); //ddc
		}

		public function play( )
		{
			    //ExternalInterface.call("printSomething", "calling tellSoundCloudWidgetToPlay\n " ); //ddc
				ExternalInterface.call("tellSoundCloudWidgetToPlay", "" ); //ddc
		}

		public function pause( )
		{
			    //ExternalInterface.call("printSomething", "calling tellSoundCloudWidgetToPlay\n " ); //ddc
				ExternalInterface.call("tellSoundCloudWidgetToPause", "" ); //ddc
		}
		

	}
}