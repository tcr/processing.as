package {
	import flash.display.Sprite;
	import processing.Processing;
	import processing.api.PMath;
	import flash.external.ExternalInterface;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.utils.describeType;
	import flash.display.StageQuality;
	import flash.text.*; // ddc
	
	import com.adobe.images.JPGEncoder;
	import flash.utils.ByteArray;
	import flash.net.URLRequestHeader;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.geom.ColorTransform;

	import flash.utils.getTimer;

import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.events.*;
import flash.geom.Rectangle;

import flash.errors.*;
import flash.events.*;
import flash.filters.*;
import flash.geom.*;
import flash.net.*;
import flash.media.*;
import flash.ui.*;
import flash.utils.*;
import flash.xml.*;

    //import flash.net.navigateToURL;
    //import flash.net.URLRequest;
    //import flash.net.URLVariables;

import base64lib.Base64;
 

import flash.system.Capabilities;


	
	[SWF(width="0", height="0", frameRate="60", backgroundColor="#ffffff")]
	
        public class processing extends Sprite {
            //FontEmbedder; // ddc, this is to embed the font, otherwise no text is shown under Linux


			public static var theButton:Sprite = new Sprite();       //ddc

			// this variable flags whether the execution of the sketch should
			// halt. We make the sketch to halt if ta delay is invoked with
			// a ridiculously big number. This is the quickest way to halt a sketch in
			// processing in any specified point (exit doesn't work as well because it
			// closes the output window).
			// We use this for running a set of tests, so that the sketch at some
			// point completely halts at a precise line and stops and we can compare with
			// the same program in processing.
			public static var haltExecution:Boolean = false;

			// see the beginning of the onEnterFrame method in PApplet.as
			// for an explanation of why
			// this variable is needed
			public static var printedSomething:Boolean = false;       //ddc
			public static var printCaseMilliseconds:int;       //ddc

			public static var PRINTSIZE:Boolean = false;       //ddc
			public static var DEBUG:Boolean = false;       //ddc
			public static var DEBUG_FOR_OO:Boolean = false;       //ddc
			public static var TIMEKEEPINGDEBUGTEXT:Boolean = false;       //ddc
			public static var TIMEKEEPING:Boolean = true;       //ddc
			public static var debugTextField:TextField = new TextField();       //ddc
			
			// this is to keep track of all the functions in the processing program
			// if there is no setup function, then we'll add it
			public static var functionNamesmyArray = new Array(); // ddc
			
			public static var lastDateOfRefresh:int = 0;       //ddc
			//public static var dialogShown:Boolean = false;       //ddc
			public static var timeLimit:int = 300;       //ddc
			
			public static var oldw = 0;
			public static var oldh = 0;
			
        
		public static var p:Processing;

// functions to enter and leave full screen mode
function goFullScreen(event:ContextMenuEvent):void
{
   //debugTextField.text = "stage w:" + stage.stageWidth + ", h:" + stage.stageHeight;
   //debugTextField.text += "\rpappl w:" + p.applet.width + ", h:" + p.applet.height;
   //stage.stageWidth = 800;
   //stage.stageHeight=600;

   //stage.fullScreenSourceRect = new Rectangle(0,0,1280,800);
   
   oldw = p.applet.width;
   oldh = p.applet.height;
   //p.applet.y = -200;

    stage.displayState = StageDisplayState.FULL_SCREEN;

	var screenScale = Capabilities.screenResolutionX / Capabilities.screenResolutionY;
	var scale = 0;
	if ((p.applet.width / p.applet.height) >= screenScale) {
		scale =  Capabilities.screenResolutionX / p.applet.width;
		p.applet.width = Capabilities.screenResolutionX;
   		p.applet.height *= scale;	
	}
	else {
		scale =  Capabilities.screenResolutionY / p.applet.height;
   		p.applet.height = Capabilities.screenResolutionY;
		p.applet.width *= scale;
	}

   p.applet.x = -(p.applet.width - oldw)/2;
	p.applet.y = -(p.applet.height - oldh)/2;

}

// An alternate full-screen function that uses hardware scaling to display the upper left corner of the stage in full screen.
function goScaledFullScreen(event:ContextMenuEvent){
   stage.scaleMode = StageScaleMode.NO_BORDER;
   var screenRectangle:Rectangle = new Rectangle(0, 0, 200, 200);
   stage.fullScreenSourceRect = screenRectangle;
   stage.displayState = StageDisplayState.FULL_SCREEN;
}

function exitFullScreen(event:ContextMenuEvent):void
{
   stage.displayState = StageDisplayState.NORMAL;
}

function onFullScreen(fullScreenEvent:FullScreenEvent):void
{
  var bFullScreen=fullScreenEvent.fullScreen;
  if (bFullScreen)
  {
    // do something  here when the display changes to full screen
  }
  else
  {
   	p.applet.width = oldw;
   	p.applet.height = oldh;
   	p.applet.x = 0;
	p.applet.y = 0;
  }

}


// function to enable and disable the context menu items,
// based on what mode we are in.
function menuHandler(event:ContextMenuEvent):void
{
   if (stage.displayState == StageDisplayState.NORMAL)
   {
      event.target.customItems[0].enabled = true;
      event.target.customItems[1].enabled = false;
   }
   else
   {
      event.target.customItems[0].enabled = false;
      event.target.customItems[1].enabled = true;
   }
}


		public function processing():void {

			// create the context menu, remove the built-in items,
			// and add our custom items
			var fullscreenCM:ContextMenu = new ContextMenu();
			fullscreenCM.addEventListener(ContextMenuEvent.MENU_SELECT, menuHandler);
			fullscreenCM.hideBuiltInItems();

			var fs:ContextMenuItem = new ContextMenuItem("Go Full Screen" );
			fs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, goFullScreen);
			fullscreenCM.customItems.push( fs );

			var xfs:ContextMenuItem = new ContextMenuItem("Exit Full Screen");
			xfs.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, exitFullScreen);
			fullscreenCM.customItems.push( xfs );

			// finally, attach the context menu to a movieclip
			this.contextMenu = fullscreenCM;

			// Assign an event handler. The event handler will be called when the screen
			// switch back and forth between normal and full-screen
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullScreen); 


			// initialize preloader
			//flash.display.Stage.displayState = flash.display.StageDisplayState.FULL_SCREEN;
			preloader = new Loader();
			preloader.contentLoaderInfo.addEventListener(Event.COMPLETE, goFullScreen);
		
			// set stage mode
			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.scaleMode = StageScaleMode.SHOW_ALL;
			
			// add callbacks
			ExternalInterface.addCallback('start', start);
			ExternalInterface.addCallback('restart', restart);
			ExternalInterface.addCallback('stopSketchExecution', stop);
			ExternalInterface.addCallback('run', run);
			
			//this one receives whether we want to keep on going with the slow sketches //ddc
			ExternalInterface.addCallback("sendToActionscript", callFromJavaScript); // ddc
			
			// call load handler
			ExternalInterface.call("ProcessingASonLoad");
			
			
			
		}



function startFullPictureUpload():void {
	var scale = 0;
	var jpgSource:BitmapData;

 	
var intermediateRectangle:BitmapData= new BitmapData (p.applet.width, p.applet.height);
    intermediateRectangle.draw(this);

var smallerSide = Math.min(p.applet.width, p.applet.height);

// basically, the only difference with uploading a thumbnail is that we don't do the resizing
var myRectangle:Rectangle= new Rectangle(0, 0, smallerSide, smallerSide);
var translateMatrix:Matrix = new Matrix();

 	if (p.applet.width >= p.applet.height){
 		scale = smallerSide/p.applet.height;
		translateMatrix.translate(-((p.applet.width*scale-smallerSide)/2), 0);
 	}
 	else{
 		scale = smallerSide/p.applet.width;
		translateMatrix.translate(0, -((p.applet.height*scale-smallerSide)/2));
 	}
 		jpgSource = new BitmapData (smallerSide, smallerSide);


var myMatrix:Matrix = new Matrix();
myMatrix.scale(scale,scale);
myMatrix.concat(translateMatrix);


var myColorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
var blendMode:String = "normal";
var smooth:Boolean = true;


//var translateMatrix:Matrix = new Matrix();
//translateMatrix.translate(70, 15);



//var myRectangle:Rectangle = new Rectangle(0, 0, 100, 80);
//var smooth:Boolean = true;

    //myBitmapData.draw(mc_2, myMatrix, myColorTransform, blendMode, myRectangle, smooth);

    jpgSource.draw(intermediateRectangle, myMatrix,myColorTransform,blendMode,myRectangle,smooth);



//debugTextField.text = "initialised bitmap space"; //ddc
			//jpgSource.draw(this);
//debugTextField.text = "got the bitmap data"; //ddc
			var jpgEncoder:JPGEncoder = new JPGEncoder(100);
			var jpgStream:ByteArray = jpgEncoder.encode(jpgSource);
//debugTextField.text = "encoded the jpg"; //ddc
			//var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			//var jpgURLRequest:URLRequest = new URLRequest("/jpg_encoder_download/?name=sketch.jpg");
			//jpgURLRequest.requestHeaders.push(header);
			//jpgURLRequest.method = flash.net.URLRequestMethod.POST;
			//jpgURLRequest.data = jpgStream;
			//flash.net.navigateToURL(jpgURLRequest, "_blank");

//var variables:MultipartVariables = new MultipartVariables();

//variables.add('file_data',jpgStream);
//variables.add('another_var','extra data');
//loader.variables = variables;
//loader.addEventListener(Event.COMPLETE,fileUploaded);
//debugTextField.text = "loading now"; //ddc
//loader.load();
//debugTextField.text = "uploaded?"; //ddc

			var encoded:String = Base64.encodeByteArray(jpgStream);
			ExternalInterface.call("sendFullPictureToJavascript", encoded);

}

		
function startThumbnailUpload():void {
//debugTextField.text = "entered the method"; //ddc
//var loader:MultipartLoader = new MultipartLoader('http://sketchpatch.appspot.com/jpg_encoder_download/'+blogTitle);
//var loader:MultipartLoader = new MultipartLoader('http://localhost:8080/jpg_encoder_download/'+blogTitle);
//debugTextField.text = "initialed MultipartLoader"; //ddc
	var scale = 0;
	var jpgSource:BitmapData;

 	//debugTextField.text = "w:" + stage.stageWidth + ", h:" + stage.stageHeight;

//ExternalInterface.call("sendThumbnailToJavascript", p.applet.width + " " + p.applet.height );
if (p == null) {
ExternalInterface.call("sendThumbnailToJavascript", "" );
return;
}


var intermediateRectangle:BitmapData= new BitmapData (p.applet.width, p.applet.height);
    intermediateRectangle.draw(this);

var myRectangle:Rectangle= new Rectangle(0, 0, 50, 50);;
var translateMatrix:Matrix = new Matrix();

 	if (p.applet.width >= p.applet.height){
 		scale = 50/p.applet.height;
 		//jpgSource = new BitmapData (this.width*scale, 50);
		translateMatrix.translate(-((p.applet.width*scale-50)/2), 0);
 	}
 	else{
 		scale = 50/p.applet.width;
 		//jpgSource = new BitmapData (50, this.height*scale);
		translateMatrix.translate(0, -((p.applet.height*scale-50)/2));
 	}
 		jpgSource = new BitmapData (50, 50);


var myMatrix:Matrix = new Matrix();
myMatrix.scale(scale,scale);
myMatrix.concat(translateMatrix);


var myColorTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
var blendMode:String = "normal";
var smooth:Boolean = true;


//var translateMatrix:Matrix = new Matrix();
//translateMatrix.translate(70, 15);



//var myRectangle:Rectangle = new Rectangle(0, 0, 100, 80);
//var smooth:Boolean = true;

    //myBitmapData.draw(mc_2, myMatrix, myColorTransform, blendMode, myRectangle, smooth);

    jpgSource.draw(intermediateRectangle, myMatrix,myColorTransform,blendMode,myRectangle,smooth);



//debugTextField.text = "initialised bitmap space"; //ddc
			//jpgSource.draw(this);
//debugTextField.text = "got the bitmap data"; //ddc
			var jpgEncoder:JPGEncoder = new JPGEncoder(100);
			var jpgStream:ByteArray = jpgEncoder.encode(jpgSource);
//debugTextField.text = "encoded the jpg"; //ddc
			//var header:URLRequestHeader = new URLRequestHeader("Content-type", "application/octet-stream");
			//var jpgURLRequest:URLRequest = new URLRequest("/jpg_encoder_download/?name=sketch.jpg");
			//jpgURLRequest.requestHeaders.push(header);
			//jpgURLRequest.method = flash.net.URLRequestMethod.POST;
			//jpgURLRequest.data = jpgStream;
			//flash.net.navigateToURL(jpgURLRequest, "_blank");

//var variables:MultipartVariables = new MultipartVariables();

//variables.add('file_data',jpgStream);
//variables.add('another_var','extra data');
//loader.variables = variables;
//loader.addEventListener(Event.COMPLETE,fileUploaded);
//debugTextField.text = "loading now"; //ddc
//loader.load();
//debugTextField.text = "uploaded?"; //ddc

			var encoded:String = Base64.encodeByteArray(jpgStream);
			ExternalInterface.call("sendThumbnailToJavascript", encoded);

}


		// this whole function by ddc
		function callFromJavaScript(dir):void {	
		
		//debugTextField.text += dir+"\r";

		  if(dir.indexOf('getStringOfBase64AppletJPG') == 0)
 		 {	//debugTextField.text = "starting upload"; //ddc
 		 	//var blogTitle:String = dir.substr(10);
 		 	
 		 	//var url:String = "http://localhost:8080/jpg_encoder_download/test";
            //var request:URLRequest = new URLRequest(url);
            //var variables:URLVariables = new URLVariables();
            //variables.exampleSessionId = new Date().getTime();
            //variables.exampleUserLabel = "guest";
            //request.data = variables;
            //navigateToURL(request);

			startThumbnailUpload();			

		  }
		  
		  if(dir.indexOf('uploadFullPicture') == 0)
 		 {	//debugTextField.text = "starting upload"; //ddc
 		 	//var blogTitle:String = dir.substr(10);
 		 	
 		 	//var url:String = "http://localhost:8080/jpg_encoder_download/test";
            //var request:URLRequest = new URLRequest(url);
            //var variables:URLVariables = new URLVariables();
            //variables.exampleSessionId = new Date().getTime();
            //variables.exampleUserLabel = "guest";
            //request.data = variables;
            //navigateToURL(request);

			startFullPictureUpload();			

		  }

		  if(dir == 'moreTime')
 		 {
		    timeLimit += 100;
		    lastDateOfRefresh = getTimer();
		    
		    
		    // now, the way to restart a sketch is different whether there is a draw method or not
		    // if there is no draw method, then the sketch is completely stopped and re-started
		    // while if there is a draw method, we keep the sketch and its state and just
		    // keep running the draw method.
		    // In case there is a draw method, we can't just run the sketch directly right here,
		    // we rather neet to set a timer to run it a bit later, and return the call from
		    // the browser (the happened because the user has clicked "continue").
		    // If we were to run the sketch directly here, the thread is still the one of
		    // the call from the javascript user clicking "continue", and in case we have to
		    // give another "slow sketch" notification and hence called the browser, you see that
		    // we have a mess of a thread that started on the browser, went into a slow sketch, and
		    // goes back to the browser. This did cause a problem where the "continue" button
		    // clicks two times, which causes new "slow sketch" notifications to pop-up
		    // and stack-up indefinetely without the user having clicked anything or being able
		    // to stop the stacking-up, and control of the tab is lost.
		    if (!p.applet.context.scope.draw ){
		    	stop();
		    	var timer:Timer = new Timer(250,1);
		    	timer.addEventListener(TimerEvent.TIMER, delayedRun);
		    	timer.start();
		    }
		    else if (p.applet.context.scope.draw ){
		    	p.applet.addAllEventListenersForMouseKeyboardAndEnterFrame();
		    }

		  }
		  if(dir == 'lessTime')
 		 {
		    timeLimit -= 100;
		    lastDateOfRefresh = 0;
		  }

		   if(dir == 'infiniteTime')
		  {
		    timeLimit = 999999999;
		    lastDateOfRefresh = 0;
		  }  
		   if(dir == 'timeKeepingDebugOn')
		  {
		    TIMEKEEPINGDEBUGTEXT = true;
		  } 
		   if(dir == 'timeKeepingDebugOff')
		  {
		    TIMEKEEPINGDEBUGTEXT = false;
		    debugTextField.text = ""; //ddc
		  } 
		}

		public function delayedRun(e:TimerEvent):void{
				    	run(this.script);
		}
		
		public function restart():void {
		    lastDateOfRefresh = 0;
		 	functionNamesmyArray = new Array();
		 	start();
		 	
        }
        
		public function start():void {
		 	
		 	
			// check if we need to reset
			if (p)
				stop();
			// create processing object
			p = new Processing();

			// attach sprite to stage
			addChild(p.applet);
			p.applet.graphics.addEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			//this.addEventListener(Event.ENTER_FRAME, callJs); //ddc
			
			// externalize objects
			externalize(p.applet.graphics);
			externalize(PMath);
			
			// reset stage variables
			stage.frameRate = 60;
			stage.quality = StageQuality.LOW;

			// call start handler
			ExternalInterface.call('ProcessingAS.onStart');
			
			
			// Tell ActionScript to render this text field using embedded fonts //ddc
			//debugTextField.embedFonts = true;  //ddc
			
			    if(DEBUG || TIMEKEEPING){
					var format1:TextFormat = new TextFormat();
					format1.font="TIMES";
					format1.size=12;
					debugTextField.setTextFormat(format1);
					
					//debugTextField.autoSize = "true";  //ddc
					debugTextField.autoSize    = TextFieldAutoSize.LEFT; //ddc
					debugTextField.wordWrap    = true; //ddc
					debugTextField.selectable  = true; //ddc
					debugTextField.multiline   = true; //ddc
					//debugTextField.border      = true; //ddc
					debugTextField.width       = 200;  //ddc

					// Use two variations of Verdana (normal, and bold) //ddc
					//debugTextField.htmlText = "<FONT FACE='TIMES' SIZE='14' >Hello world</FONT>"; //ddc
					//debugTextField.text = "Hello world"; //ddc
					// Enable FlashType (i.e., Saffron) text rendering //ddc
					debugTextField.antiAliasType = AntiAliasType.ADVANCED; //ddc
					// Add the text field to the display list //ddc
					addChild(debugTextField); //ddc
					//debugTextField.text = "Debug field ready"; //ddc
					
					//addPlayButton();
					

			}

		}
		
		function addPlayButton() {
					var buttonAttachX = 20;
					var buttonAttachY = 20;
					var buttonSquareSide = 55;

					addChild(theButton);
					theButton.addEventListener(MouseEvent.CLICK,clickedPlayButton);
					theButton.graphics.beginFill(0xd5d5d5);					

					theButton.graphics.drawRect(buttonAttachX,buttonAttachY,buttonSquareSide,buttonSquareSide);
					theButton.graphics.beginFill(0xffffff);
					
					// top left smoothed corner
					theButton.graphics.drawRect(buttonAttachX,buttonAttachY,2,1);
					theButton.graphics.drawRect(buttonAttachX,buttonAttachY,1,2);

					// top right
					theButton.graphics.drawRect(buttonAttachX+buttonSquareSide-2,buttonAttachY,2,1);
					theButton.graphics.drawRect(buttonAttachX+buttonSquareSide-1,buttonAttachY,1,2);

					// bottom left
					theButton.graphics.drawRect(buttonAttachX,buttonAttachY+buttonSquareSide-1,2,1);
					theButton.graphics.drawRect(buttonAttachX,buttonAttachY+buttonSquareSide-2,1,2);

					// bottom right
					theButton.graphics.drawRect(buttonAttachX+buttonSquareSide-2,buttonAttachY+buttonSquareSide-1,2,1);
					theButton.graphics.drawRect(buttonAttachX+buttonSquareSide-1,buttonAttachY+buttonSquareSide-2,1,2);

					var arrowOffsetX = 20;
					var arrowOffsetY = 10;

					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX,buttonAttachY+arrowOffsetY,1,36);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+1,buttonAttachY+arrowOffsetY,1,36);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+2,buttonAttachY+arrowOffsetY+1,1,34);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+3,buttonAttachY+arrowOffsetY+2,1,32);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+4,buttonAttachY+arrowOffsetY+3,1,30);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+5,buttonAttachY+arrowOffsetY+4,1,28);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+6,buttonAttachY+arrowOffsetY+5,1,26);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+7,buttonAttachY+arrowOffsetY+6,1,24);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+8,buttonAttachY+arrowOffsetY+7,1,22);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+9,buttonAttachY+arrowOffsetY+8,1,20);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+10,buttonAttachY+arrowOffsetY+9,1,18);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+11,buttonAttachY+arrowOffsetY+10,1,16);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+12,buttonAttachY+arrowOffsetY+11,1,14);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+13,buttonAttachY+arrowOffsetY+12,1,12);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+14,buttonAttachY+arrowOffsetY+13,1,10);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+15,buttonAttachY+arrowOffsetY+14,1,08);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+16,buttonAttachY+arrowOffsetY+15,1,06);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+17,buttonAttachY+arrowOffsetY+16,1,04);
					theButton.graphics.drawRect(buttonAttachX+arrowOffsetX+18,buttonAttachY+arrowOffsetY+17,1,02);
					
					theButton.graphics.endFill();

		}
		
		function clickedPlayButton(event:MouseEvent){
			debugTextField.text = "Someone has clicked the button";
		}
		
		public function stop():void {
			// stop scripts
			p.stop();
			
			// remove sprites
			removeChild(p.applet);
			p.applet.graphics.removeEventListener(flash.events.Event.RESIZE, resizeHandler);
			
			// delete processing object
			p = null;
			
			// call stop handler
			ExternalInterface.call('ProcessingAS.onStop');
		}
		
		public function run(script:String, images:Array = null):void {
		

			// start script
			start();
			
			// save current script
			this.script = script;
			
			// start method
			if (images && images.length) {
				// preload images
				preloadStack = images;
				preloadImages();
			} else {
				// start immediately
				parseAndEvaluate();
			}


		}
		
		private var script:String = '';
		
		private function parseAndEvaluate():void {
			// evaluate code
						
			
			// this flag might be true if a delay with an exceedingly long number
			// or an exit(); has been invoked
			haltExecution = false;

			p.parse(script);
			
			
			// here we check if there is a setup method.
			// if there is no setup method, we add it to the program and then
			// we re-parse the program.
			// !!! This mechanism is not perfect because there could be a setup
			// method in a class, in that case we wouldn't recognize that there
			// is no actual setup method.
			
			var isThereaSetupMethod:Boolean = false;
			var isThereaDrawMethod:Boolean = false;
			for( var z:int = 0 ; z < functionNamesmyArray.length ; z++){
 		       if (functionNamesmyArray[z]=="setup") isThereaSetupMethod = true;
		       if (functionNamesmyArray[z]=="draw") isThereaDrawMethod = true;
			   //debugTextField.text = functionNamesmyArray[z] + "\n";
			}
			
			// if there is no setup or draw method, then we wrap all the script in
			// a setup function/
			// if there is a setup method OR a draw method, then the interpreter will
			// pick one or the other.
			if (!(isThereaSetupMethod || isThereaDrawMethod)){
				script = "public void setup() {\n"+script+"\n}";
				p.parse(script);
				//stop();
				//restart();
				//run(script);
			}
			

			

			//ddc here we start to take the time cause we can't wait to take the time until the
			// first frame is drawn. If we did that, the sketches that enter a deadly loop
			// before the first frame is drawn hang the browser.
			lastDateOfRefresh = getTimer() + 500;

			p.evaluate();
			
			// start the Processing API
			p.start();
		}
		
		public function resizeHandler(e:Event):void {
			// dispatch resize handler
			ExternalInterface.call('ProcessingAS.onResize', p.applet.graphics.width, p.applet.graphics.height);
			// move sprite
			x = -(p.applet.graphics.width / 2);
			y = -(p.applet.graphics.height / 2);
		}
		
		private var preloadStack:Array = [];
		private var preloader:Loader;
		
		public function preloadImages():void {
			// check that there is an image to be loaded
			if (!preloadStack.length) {
				// done preloading
				parseAndEvaluate();
				return;
			}
		
			// load image path
			preloader.load(new URLRequest(preloadStack[preloadStack.length - 1][1]));
		}
		
		private function preloaderHandler(e:Event):void {
			// pop stack and save preloaded image
			var path:Array = preloadStack.pop();
			var image:BitmapData = new BitmapData(preloader.content.width, preloader.content.height);
			image.draw(preloader.content);
			p.applet.loadImage(path[0], image);
			
			// preload next image
			preloadImages();
		}
		
		private function externalize(obj:Object):void {
			// add callbacks
			var description:XML = describeType(obj);
			for each (var method:String in description..method.(@declaredBy==description.@name).@name)
				ExternalInterface.addCallback(method, obj[method]);
		}
	}
}
