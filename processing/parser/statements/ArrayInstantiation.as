package processing.parser.statements
{
	import processing.parser.*;
	import processing.api.ArrayList;


	public class ArrayInstantiation implements IExecutable
	{
		public var type:Type;
		public var size1:IExecutable;
		public var size2:IExecutable;
		public var size3:IExecutable;
	
		public function ArrayInstantiation(t:Type, s1:IExecutable, s2:IExecutable = null, s3:IExecutable = null) {
			type = t;
			size1 = s1;
			size2 = s2;
			size3 = s3;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;
			
			// return new ArrayList object
			return new ArrayList(size1.execute(context), size2 ? size2.execute(context) : 0, size3 ? size3.execute(context) : 0, type);
		}
	}
}
