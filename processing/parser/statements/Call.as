package processing.parser.statements
{
	import processing.parser.*;

	public class Call implements IExecutable
	{
		public var method:IExecutable;
		public var args:Array;
	
		public function Call(m:IExecutable, a:Array = null) {
			method = m;
			args = a;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// iterate args statements
			var parsedArgs:Array = [];
			for each (var arg:IExecutable in args)
				parsedArgs.push(arg.execute(context));
			// apply function
			if (processing.DEBUG) processing.debugTextField.text += "\r call"; //ddc
			
			var returnValue;
			
			try{
			returnValue = method.execute(context).apply(context, parsedArgs);
			//processing.debugTextField.text += "\r a natural return";
			}
			catch (ret:Return)
			{
			// handle returns
			//[TODO] do something with type
			//processing.debugTextField.text += "\r a proper return!";
			return ret.value.execute(context);
			}
			
			return returnValue;

			
			return method.execute(context).apply(context, parsedArgs);
		}
	}
}
