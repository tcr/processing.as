package processing.parser.statements
{
	import processing.parser.*;


	public class Literal implements IExecutable
	{
		public var value:*;
	
		public function Literal(v:*) {
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// return literal
			return value;
		}
	}
}
