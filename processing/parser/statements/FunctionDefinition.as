package processing.parser.statements
{
	import processing.parser.*;


	public class FunctionDefinition implements IExecutable
	{
		public var identifier:String;
		public var type:Type;
		public var params:Array;
		public var body:IExecutable;
	
		public function FunctionDefinition(i:String, t:Type, p:Array, b:IExecutable) {
			identifier = i;
			type = t;
			params = p;
			body = b;
		}
		
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// check that a variable is not already defined
			//[TODO] this shouldn't have " || !context.scope[identifier]"; must remove predefined .setup from Processing API context!
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r *** attempting to define function: "+identifier; //ddc
			if ( !context.scope.hasOwnProperty(identifier) || !context.scope[identifier])
			{

				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r *** defining function: "+identifier; //ddc

				// define wrapper function
				context.scope[identifier] = function ()
				{
					// check that an overloader be available
					if (!arguments.callee.overloads.hasOwnProperty(arguments.length))
						throw new Error('Function called without proper argument number.');

					// convert arguments object to array
					for (var args:Array = [], i:int = 0; i < arguments.length; i++)
						args.push(arguments[i]);
					// call overload
					return arguments.callee.overloads[args.length].apply(null, args);
				}
				
				if (context.nameOfClassItBelongsTo !== context.nameOfClassItWasOriginallyDefinedIn) {
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r *** adding renamed aliases of method - part1 "+"Overload"+context.nameOfClassItWasOriginallyDefinedIn+identifier; //ddc
					// adding the alias that makes super. work
					context.scope["OverloadFor"+context.nameOfClassItBelongsTo+context.nameOfClassItWasOriginallyDefinedIn+identifier] = context.scope[identifier];
				}
				

				// create overloads array
				context.scope[identifier].overloads = [];
				
				if (context.nameOfClassItBelongsTo !== context.nameOfClassItWasOriginallyDefinedIn) {
					// adding the alias that makes super. work
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r *** adding renamed aliases of method - part2 "; //ddc
					context.scope["OverloadFor"+context.nameOfClassItBelongsTo+context.nameOfClassItWasOriginallyDefinedIn+identifier].overloads = [];
				}

			}
			else if (context.scope[identifier] && !context.scope[identifier].hasOwnProperty('overloads'))
			{
				// cannot define function with name of declared variable
				throw new Error('Cannot declare function "' + identifier + '" as it is already defined.');
			}


			// add overload
			//[TODO] overloads based on param type
			context.scope[identifier].overloads[params.length] = function (... args)
			{
				
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r calling function: "+identifier; //ddc
				
				var funcContext:ExecutionContext;

				if (identifier=="super"){
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r called super from class "+context.nameOfClassItBelongsTo; //ddc
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += " which extends "+ ClassDefinition.allClassDefinitions[context.nameOfClassItBelongsTo].extendedClassName; //ddc
					funcContext = context;
				}
				else {				
					// check that this be called as a function
					//[TODO] that
					// create new evaluator context
					funcContext = new ExecutionContext({}, context);
				}

				// parse args
				for (var i in args)
				{
				//[TODO] what happens when args/params differ?
				//[TODO] maybe shortcut something here?
					(new VariableDefinition(params[i][0], params[i][1])).execute(funcContext);
					(new Assignment(new Reference(new Literal(params[i][0])), new Literal(args[i]))).execute(funcContext);
				}
				
				try
				{
						// evaluate body
						body.execute(funcContext);
				}
				catch (ret:Return)
				{
					// handle returns
					//[TODO] do something with type
					return ret.value.execute(funcContext);
				}
			}
			
			if (context.nameOfClassItBelongsTo !== context.nameOfClassItWasOriginallyDefinedIn) {
				// adding the alias that makes super. work
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r *** adding renamed aliases of method - part3 "; //ddc
				context.scope["OverloadFor"+context.nameOfClassItBelongsTo+context.nameOfClassItWasOriginallyDefinedIn+identifier].overloads[params.length] = context.scope[identifier].overloads[params.length];
			}

		}
	}
}
