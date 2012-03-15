package processing.parser.statements
{
	import processing.parser.*;


	public class ObjectInstantiation implements IExecutable
	{
		public var method:IExecutable;
		public var args:Array;
	
		public function ObjectInstantiation(m:IExecutable, a:Array = undefined) {

				// operand 0  contains the class to be instantiated
				// operand 1  contains an array with all the parameters to pass to the
				//             constructor method


			method = m;
			args = a;

		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;


			// parse class
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r parsing the class "; //ddc
			var objClass:* = method.execute(context);
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r parsed class " + objClass; //ddc


			// we have been called from one of the "static alias classes"
			//  -those shouldn't be allowed to create any object - so in that case
			// we just return
			
			//processing.debugTextField.text += "\r instantiating an object "; //ddc
			if (context.dontRunConstructorMethodOrConstructObjects) {
				//processing.debugTextField.text += "\r ... but I'm in a class where I'm not instantiating anything"; //ddc
				return function Function() {};
			}


			// iterate args statements (i.e. the arguments could be statements that need to be
			// evaluated).

			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r about to instance an object of class " + objClass + " with " + args.length + " arguments"; //ddc

			var parsedArgs:Array = [];
			for each (var arg:IExecutable in args) {
				parsedArgs.push(arg.execute(context));
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r     argument " +(parsedArgs.length - 1)+ " : "+parsedArgs[parsedArgs.length - 1]; //ddc
			}
			
			// create object instance
			switch (args.length)
			{
				case 0: return new objClass();
				case 1: return new objClass(parsedArgs[0]);
				case 2: return new objClass(parsedArgs[0], parsedArgs[1]);
				case 3: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2]);
				case 4: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3]);
				case 5: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4]);
				case 6: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5]);
				case 7: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6]);
				case 8: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6], parsedArgs[7]);
				case 9: return new objClass(parsedArgs[0], parsedArgs[1], parsedArgs[2], parsedArgs[3], parsedArgs[4], parsedArgs[5], parsedArgs[6], parsedArgs[7], parsedArgs[8]);
				default: throw new Error('Constructor called with too many arguments.');
			}
		}
	}
}
