package processing.parser.statements
{
	import processing.parser.*;


	public class Return extends Error implements IExecutable
	{
		public var value:*;
	
		public function Return(v:*) {
			super('Invalid return');
			
			value = v;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// throw this return
			//processing.debugTextField.text += "\r about to throw a return"; //ddc
			throw this;
		}
	}
}
