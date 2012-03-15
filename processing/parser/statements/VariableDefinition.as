package processing.parser.statements
{
	import processing.parser.*;


	public class VariableDefinition implements IExecutable
	{
		public var identifier:String;
		public var type:Type;
	
		public function VariableDefinition(i:String, t:Type) {
			identifier = i;
			type = t;
		}
	
		public function execute(context:ExecutionContext):*
		{
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r defining variable "+ identifier; //ddc

			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

//[TODO] do something with type
			// define variable (by default, 0)
			context.scope[identifier] = 0;
		}
	}
}
