package processing.parser.statements
{
	import processing.parser.*;

	public class Assignment implements IExecutable
	{
		public var reference:Reference;
		public var value:IExecutable;
	
		public function Assignment(r:Reference, v:IExecutable)
		{
			reference = r;
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{

			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r assigning " + value + " to " + reference;


			// reduce reference
			var ref:Array = reference.reduce(context);
			// set value
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r executing the value part of the assignment " ;
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r  the context I'm passing is  "
			
			
			context.debug() ;
			return ref[1][ref[0]] = value.execute(context);
		}
	}
}
