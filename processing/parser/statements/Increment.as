package processing.parser.statements
{
	import processing.parser.*;


	public class Increment implements IExecutable
	{
		public var reference:Reference;
	
		public function Increment(r:Reference) {
			reference = r;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// get simplified reference
			var ref:Array = reference.reduce(context);
			// increment and return
			return (++ref[1][ref[0]]);
		}
	}
}
