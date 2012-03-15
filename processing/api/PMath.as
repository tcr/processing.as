package processing.api {
	public class PMath {

		// Calculation



		static public function log( aNumber:Number):Number

		{

			return Math.log( aNumber);

		}

		static public function min( aNumber:Number, aNumber2:Number ):Number

		{

			return Math.min( aNumber, aNumber2 );

		}
	

		static public function max( aNumber:Number, aNumber2:Number ):Number

		{

			return Math.max( aNumber, aNumber2 );

		}



		static public function round( aNumber:Number ):Number

		{

			return Math.round( aNumber );

		}



		static public function dist( x1:Number, y1:Number, x2:Number, y2:Number ):Number

		{

			return Math.sqrt( Math.pow( x2 - x1, 2 ) + Math.pow( y2 - y1, 2 ) );

		}



		static public function pow( aNumber:Number, aExponent:Number ):Number

		{

			return Math.pow( aNumber, aExponent );

		}



		static public function floor( aNumber:Number ):Number

		{

			return Math.floor( aNumber );

		}



		static public function sqrt( aNumber:Number ):Number

		{

			return Math.sqrt( aNumber );

		}



		static public function abs( aNumber:Number ):Number

		{

			return Math.abs( aNumber );

		}



		static public function constrain( aNumber:Number, aMin:Number, aMax:Number ):Number

		{

			return Math.min( Math.max( aNumber, aMin ), aMax );

		}



		static public function norm( value:Number, istart:Number, istop:Number ):Number

		{

			return map( value, istart, istop, 0, 1 );

		}



		static public function lerp( value1:Number, value2:Number, amt:Number ):Number

		{

			return value1 + ((value2 - value1) * amt);

		}



		static public function sq( aNumber:Number ):Number

		{

			return Math.pow( aNumber, 2 );

		}

	

		static public function ceil( aNumber:Number ):Number

		{

			return Math.ceil( aNumber );

		}



		static public function map( value:Number, istart:Number, istop:Number, ostart:Number, ostop:Number ):Number

		{

			return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));

		}



		// Trigonometry



		static public function tan( aNumber:Number ):Number

		{

			return Math.tan( aNumber );

		}



		static public function sin( aNumber:Number ):Number

		{

			return Math.sin( aNumber );

		}

		

		static public function cos( aNumber:Number ):Number

		{

			return Math.cos( aNumber );

		}



		static public function degrees( aAngle:Number ):Number

		{

			return ( aAngle / Math.PI ) * 180;

		}



		static public function atan2( aNumber:Number, aNumber2:Number ):Number

		{

			return Math.atan2( aNumber, aNumber2 );

		}

		

		static public function radians( aAngle:Number ):Number

		{

			return ( aAngle / 180 ) * Math.PI;

		}



		// Random



		// From: http://freespace.virgin.net/hugo.elias/models/m_perlin.htm

		static public function noise( x:Number, y:Number = undefined, z:Number = undefined ):Number

		{

			return arguments.length >= 2 ?

				PerlinNoise_2D( x, y ) :

				PerlinNoise_2D( x, x );

		}

	

		static private function Noise(x, y):Number

		{

			var n = x + y * 57;

			n = (n<<13) ^ n;

			return Math.abs(1.0 - (((n * ((n * n * 15731) + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0));

		}

	

		static private function SmoothedNoise(x, y):Number

		{

			var corners = ( Noise(x-1, y-1)+Noise(x+1, y-1)+Noise(x-1, y+1)+Noise(x+1, y+1) ) / 16;

			var sides	 = ( Noise(x-1, y)	+Noise(x+1, y)	+Noise(x, y-1)	+Noise(x, y+1) ) /	8;

			var center	=	Noise(x, y) / 4;

			return corners + sides + center;

		}

	

		static private function InterpolatedNoise(x, y):Number

		{

			var integer_X		= Math.floor(x);

			var fractional_X = x - integer_X;

	

			var integer_Y		= Math.floor(y);

			var fractional_Y = y - integer_Y;

	

			var v1 = SmoothedNoise(integer_X,		 integer_Y);

			var v2 = SmoothedNoise(integer_X + 1, integer_Y);

			var v3 = SmoothedNoise(integer_X,		 integer_Y + 1);

			var v4 = SmoothedNoise(integer_X + 1, integer_Y + 1);

	

			var i1 = Interpolate(v1 , v2 , fractional_X);

			var i2 = Interpolate(v3 , v4 , fractional_X);

	

			return Interpolate(i1 , i2 , fractional_Y);

		}

	

		static private function PerlinNoise_2D(x, y):Number

		{

				var total = 0;

				var p = 0.25;

				var n = 3;

	

				for ( var i = 0; i <= n; i++ )

				{

						var frequency = Math.pow(2, i);

						var amplitude = Math.pow(p, i);

	

						total = total + InterpolatedNoise(x * frequency, y * frequency) * amplitude;

				}

	

				return total;

		}

	  /**
	   * Provide the tangent at the given point on the bezier curve.
	   * Fix from davbol for 0136.
	   */
	  static public function bezierTangent(a, b, c, d, t):Number {
	    return (3*t*t * (-a+3*b-3*c+d) +
	            6*t * (a-2*b+c) +
	            3 * (-a+b));
	  }




		static public function bezierPoint(a, b, c, d, t):Number
		{
			var tm = 1 - t;
			var t1 = a * Math.pow(tm,3);
			var t2 = 3 * Math.pow(tm,2) * t * b;
			var t3 = 3 * Math.pow(t , 2) * tm * c;
			var t4 = Math.pow(t , 3) * d;
			var B = t1 + t2 + t3 + t4;
			//processing.debugTextField.text += "\nentered bezierPoint and returning " + B;
			return B;
		}

		static private function Interpolate(a, b, x):Number

		{

			var ft = x * Math.PI;

			var f = (1 - Math.cos(ft)) * .5;

			return a*(1-f) + b*f;

		}



		static public function randomSeed( aValue )

		{

			//[TODO]

		}



		static public function random( aMin, aMax = null ):Number

		{

			return arguments.length == 2 ?

				aMin + (Math.random() * (aMax - aMin)) :

				Math.random() * aMin;

		}



		//=========================================================

		// Constants

		//=========================================================



		static public const HALF_PI:Number = Math.PI / 2;

		static public const TWO_PI:Number = Math.PI * 2;

		static public const PI:Number = Math.PI;

	}

}
