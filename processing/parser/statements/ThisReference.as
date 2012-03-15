package processing.parser.statements
{
	import processing.parser.*;


	public class ThisReference implements IExecutable
	{
		public function ThisReference()
		{
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// climb context inheritance to find defined thisObject
			for (var c:ExecutionContext = context;
			    c && !c.thisObject;
			    c = c.parent);
			return c ? c.thisObject : undefined;
		}
	}
}
