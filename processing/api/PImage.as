package processing.api {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	

	public class PImage extends EventDispatcher {
		// graphics data
		public var bitmapData:BitmapData;

		// pixels array
		public var pixels:Array;
		
		//constructor
		
		public function PImage(w:int, h:int):void {
			// create bitmapdata
			//processing.debugTextField.text += "\r building a PImage with int parameters: " + w + " , " + h; //ddc
			bitmapData = new BitmapData(w, h);
		} 
		
		// image width/height

		
		public function get width():Number { return bitmapData.width; }
		public function get height():Number { return bitmapData.height; }
		
		public function get( x:int = 0, y:int = 0, w:int = undefined, h:int = undefined ):*
		{
			if ( arguments.length == 0 || arguments.length == 4 ){
				// normalize dimensions
				if (arguments.length == 0) {
					w = width;
					h = height;
				}
				// create new image

				var img:PImage = new PImage(w, h);
				// copy bitmapData

				img.bitmapData.copyPixels(bitmapData, new Rectangle(x, y, w, h), new Point(0, 0));
				return img;
			}
			else if ( arguments.length == 2 ){
				// return pixel
				return bitmapData.getPixel32(x, y);
			}
		}
	
		public function set( x:int, y:int, color:uint ):void {
//[TODO] should this instantly nullify pixels[] array?
			bitmapData.setPixel32(x, y, color);
		}
		
		public function save( file )
		{
//[TODO] yeah, right	
		}
		
		private var _mask:PImage;
		public function mask(m:PImage) {
			_mask = m;
		}
		public function loadPixels() {
			// serialize pixel array

			pixels = new Array();
			for (var y:int = 0; y < height; y++)
			for (var x:int = 0; x < width; x++)

			pixels.push(bitmapData.getPixel32(x, y));
		}

		
		public function updatePixels() {
		// map pixel array to bitmapdata
			if (pixels) {
				for (var y:int = 0; y < height; y++)
					for (var x:int = 0; x < width; x++)
						bitmapData.setPixel32(x, y, pixels[(width * y) + x]);
			}
		}
	}
	}
