package processing {
	import processing.api.PApplet;
	import processing.parser.Parser;
	import processing.parser.statements.IExecutable;

	public class Processing {
		public var applet:PApplet;
		public var code:IExecutable;

		public function Processing():void {
			// create applet
			applet = new PApplet();
		}
		
		public function parse(c:String):* {
			// parse code
			code = (new Parser()).parse(c);
		}

		public function evaluate():* {
			return code.execute(applet.context);
		}
		
		public function start():void {
			// start applet
			applet.start();
		}
		
		public function stop():void {
			// stop applet

			applet.removeAllEventListenersForMouseKeyboardAndEnterFrame();
		}
	}
}
