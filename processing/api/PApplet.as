package processing.api {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import processing.api.PGraphics;
	import processing.parser.ExecutionContext;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.utils.getTimer;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer; //ddc

	public class PApplet extends Bitmap {
		public var graphics:PGraphics;
		public var context:ExecutionContext;

		public function PApplet() {
			// create main graphics object
			graphics = new PGraphics(100, 100, this);

			// create evaluation context
			// the evaluation context has to contain all the Actionscript classes that you
			// might want to instantiate from the processing program,
			// and variables that you know you want to read/write from actionscript
			// or from the processing program directly as variables
			// (you can change the state also using functions, for example size(1,5) does
			// change the state of the interpreter, but nut by tweaking directly
			// some variables from the processing file)
			// so for example we need to add here frameCount and PVector
			// (although obviosly both need to be dealt with in Actionscript, which so far
			// is not the case)
			// also pmouseX, pmouseY seems to be never updated from the interpreter
			// 
			// 
			context = new ExecutionContext(
			    {
				Math: PMath,
				Minim: Minim,
				AudioPlayer: AudioPlayer,
				ArrayList: ArrayList,
				PImage: PImage,
				AniSprite: AniSprite,
				pmouseX: 0,
				pmouseY: 0,
				mouseX: 0,
				mouseY: 0,
				frameCount: 0
			    }, new ExecutionContext(PMath, new ExecutionContext(graphics)));
			    
			// initialize images array
			images = {};
		}
		
		public function addAllEventListenersForMouseKeyboardAndEnterFrame():void {
			// attach event listeners
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);	
		}

		public function start():void {
			// attach event listeners
			addAllEventListenersForMouseKeyboardAndEnterFrame();

			// by default, the canvas size it 100x100 and has a light
			// gray backgound, so let's do that
			graphics.curBackground = 0xFFcccccc;
			graphics.size(100,100);
			//graphics.background();


			// tell the browser that the applet is actually running
			// (which is not to be taken for granted, there could
			// have been errors during the parsing...)
			ExternalInterface.call("startedRunning",""); //ddc

		
	try{
			// setup function
			if (context.scope.setup)
			{   			    
			    // we run the setup method
				context.scope.setup();
			}

			// draw function
			if (context.scope.draw)
			{
				redrawFrame();
			}
			else {
			    // if there is no draw function, we ran the setup function and there
			    // is nothing left to do, we can notify the browser that there isn't
			    // much else going on here.
			    // practically speaking, this can be used for example to change a play
			    // button into a rewind button, or a "playing..." message into a
			    // "done playing" message.
				ExternalInterface.call("finishedRunning",""); //ddc
			}
			}
			catch (a:UnresponsiveSketchError){ processing.debugTextField.text += "\r throwing an exce";}
		}
		
		public function removeAllEventListenersForMouseKeyboardAndEnterFrame():void {
			// remove event listeners
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private var isMousePressed:Boolean = false;

		private function onMouseMove( e:MouseEvent )
		{
			context.scope.pmouseX = context.scope.mouseX;
			context.scope.pmouseY = context.scope.mouseY;
			context.scope.mouseX = mouseX;
			context.scope.mouseY = mouseY;

			if ( typeof context.scope.mouseMoved == "function" )
			{
				context.scope.mouseMoved();
			}
			if ( isMousePressed && typeof context.scope.mouseDragged == "function" )
			{
				context.scope.mouseDragged();
			}			
		}
		
		private function onMouseDown( e:MouseEvent )
		{
			isMousePressed = true;
		
			if ( typeof context.scope.mousePressed == "function" )
			{
				context.scope.mousePressed();
			}
			else
//[TODO] do this with var/function differences
			{
				context.scope.mousePressed = true;
			}
		}
		
		private function onMouseUp( e:MouseEvent )
		{
			isMousePressed = false;
		
			if ( typeof context.scope.mouseReleased == "function" )
			{
				context.scope.mouseReleased();
			}
			
			if ( typeof context.scope.mousePressed != "function" )
			{
				context.scope.mousePressed = false;
			}
		}
		
		private var isKeyDown:Boolean = false;
		
		private function onKeyDown( e:KeyboardEvent )
		{
			isKeyDown = true;

			context.scope.key = e.keyCode + 32;

			if ( e.shiftKey )
			{
				context.scope.key = String.fromCharCode(context.scope.key).toUpperCase().charCodeAt(0);
			}

			if ( typeof context.scope.keyPressed == "function" )
			{
				context.scope.keyPressed();
			}
			else
			{
				context.scope.keyPressed = true;
			}
		}
		
		private function onKeyUp( e:KeyboardEvent )
		{
			isKeyDown = false;

			if ( typeof context.scope.keyPressed != "function" )
			{
				context.scope.keyPressed = false;
			}

			if ( typeof context.scope.keyReleased == "function" )
			{
				context.scope.keyReleased();
			}
		}

		public var enableLoop:Boolean = true;

		private function onEnterFrame( e:Event )
		{
			// ddc
			// this is a bad hack to an ackward behaviour:
			// when you do a print/println you basically do an EnternalInterface call
			// to javascript, which prints out the text in a textbox for you.
			// The trick is that when that happens, additional enterFrame events are queued up
			// for some unexplained reason.
			// So this means that when you have a print/println, the draw method
			// would be re-run as soon as it finishes. So, basically, sketches that
			// do a println/print would always run at the maximum framerate, even though
			// the user has set frameRate() to some low value.
			// In order for this behaviour to go away, we keep a flag that remembers if
			// we did a print/println, and also we keep the milliseconds
			// of when the last draw method finished.
			// In case we do see that a print/println happened, then we check the time
			// and compare against the frameRate value.
			// If it's too early then we return from this draw() invokation
			// otherwise we set the flag to false and we proceed with the drawing.
			if (processing.printedSomething) {
			    if (getTimer() - processing.printCaseMilliseconds < 1000/stage.frameRate){
					return;
				}
				processing.printedSomething = false;

			}
			
			if (processing.PRINTSIZE) {
				processing.debugTextField.text = "stage w:" + stage.stageWidth + ", h:" + stage.stageHeight;
				processing.debugTextField.text += "\rpappl w:" + processing.p.applet.width + ", h:" + processing.p.applet.height;
			}

			//trace(getTimer()); // ddc
			if (processing.TIMEKEEPING) {
				if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text = "time since last refreshed: " + (getTimer()-processing.lastDateOfRefresh); //ddc
				processing.lastDateOfRefresh = getTimer(); //ddc
				//processing.debugTextField.text = processing.debugTextField.text + "\r time: " + processing.lastDateOfRefresh; //ddc
				if (processing.TIMEKEEPINGDEBUGTEXT) processing.debugTextField.text += "\r time when refreshed: " + processing.lastDateOfRefresh; //ddc
			}
			
			if (enableLoop && context.scope.draw)
			{
					context.scope.frameCount++;
					redrawFrame();
					// see the beginning of the method for the reason
					// why we need to store this time.
					if (processing.printedSomething) {
					  processing.printCaseMilliseconds =  getTimer();
					}
			}
		}

				// this function by ddc
		public function notifyUserOfSlowSketch():void { //ddc
				
				//dialogShown = true;
				processing.lastDateOfRefresh = 0;
				//applet.stage.frameRate = 0.01;
				//stop();
				
				ExternalInterface.call("sendToJavaScript", "This sketch is slow and is making your system unresponsive. To continue anyway, click on 'give it more time'"); //ddc
		} //ddc


		public function redrawFrame():void {
			// begin drawing
				graphics.beginDraw()
				graphics.pushMatrix();
				// call user-defined draw functon

				context.scope.draw();
			// end drawing
				graphics.popMatrix();
				graphics.endDraw();	
		}
		
		// image reference object
		private var images:Object;
		
		public function loadImage(path:String, image:BitmapData):void {
			images[path] = image;
		}
		
		public function getImage(path:String):BitmapData {
			return images[path];
		}
	}
}