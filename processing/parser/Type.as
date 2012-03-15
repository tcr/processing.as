package processing.parser
{
	import processing.parser.*;
	import processing.parser.statements.*;

	public class Type
	{
		public var type:*;
		public var dimensions:int = 0;
	
		public function Type(t:*, d:int = 0) {
			type = t;
			dimensions = d;
		}
	}
}
