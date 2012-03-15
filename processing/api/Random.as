package processing.api {
	public class Random {
		public var haveNextNextGaussian:Boolean = false;
		public var nextNextGaussian:Number = 0;

		public function Random( )
		{
		}
		
		public function nextGaussian()
		{
			if (haveNextNextGaussian) {
				haveNextNextGaussian = false;

				return nextNextGaussian;
			} else {
				var v1, v2, s;
				do { 
					v1 = 2 * random(1) - 1;	 // between -1.0 and 1.0
					v2 = 2 * random(1) - 1;	 // between -1.0 and 1.0
					s = v1 * v1 + v2 * v2;
				} while (s >= 1 || s == 0);
				var multiplier:Number = Math.sqrt(-2 * Math.log(s)/s);
				nextNextGaussian = v2 * multiplier;
				haveNextNextGaussian = true;

				return v1 * multiplier;
			}
		}
	}
}