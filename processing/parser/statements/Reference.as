package processing.parser.statements
{
	import processing.parser.*;


	public class Reference implements IExecutable
	{
		public var identifier:IExecutable;
		public var base:IExecutable;
	
		public function Reference(i:IExecutable, b:IExecutable = null)
		{
			identifier = i;
			base = b;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// get simplified reference
			var ref:Array = reduce(context);
			// return value
			return ref ? ref[1][ref[0]] : undefined;
		}
		
		// reduce to [identifier, base] array pair for assignments
		public function reduce(context:ExecutionContext):Array
		{
			// evaluate identifier
			var identifier:String = this.identifier.execute(context);
			// evaluate base reference in current context
			if (base)
			{
				// base object exists
				var base:Object = this.base.execute(context);
			}
			else
			{
				// climb context inheritance to find declared identifier
				for (var c:ExecutionContext = context;
				    c && !c.scope.hasOwnProperty(identifier);
				    c = c.parent);
				if (!c)
					return null;
				var base:Object = c.scope;
			}

			// return reduced reference
			return [identifier, base];
		}
	}
}
