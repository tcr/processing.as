package processing.parser.statements
{
	import processing.parser.*;


	public class Break extends Error implements IExecutable
	{
		public var level:int = 1;
	
		public function Break(l:int = 1) {
			super('Invalid break');
		
			level = l;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// throw exception
			throw new Break(level);
		}
	}
}
