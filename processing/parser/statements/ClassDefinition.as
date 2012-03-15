package processing.parser.statements
{
	import processing.parser.*;
	import flash.text.TextField;


	public class ClassDefinition implements IExecutable
	{
		public var identifier:String;
		public var constructorBody:IExecutable;
		public var publicBody:IExecutable;
		public var privateBody:IExecutable;

		public var debugTextField:TextField; //ddc
		public var extendedClassName:String; //ddc

		// here we'll store all the class definitions
		public static var allClassDefinitions:Object = new Object();

		public var dontRunConstructorMethodOrConstructObjects:Boolean = false;

	
		public function ClassDefinition(i:String, extendedClassName:String, c:IExecutable, pu:IExecutable, pr:IExecutable, debugTextField:TextField, dontRunConstructorMethodOrConstructObjects:Boolean) {
			identifier = i;
			constructorBody = c;
			publicBody = pu;
			privateBody = pr;
			this.dontRunConstructorMethodOrConstructObjects = dontRunConstructorMethodOrConstructObjects;
			
			this.debugTextField = debugTextField;
			this.extendedClassName = extendedClassName;
			
			allClassDefinitions[i] = this;

			//debugTextField.text += "\r classes so far:  ";
			//for (var key in allClassDefinitions)
			//	debugTextField.text += " "+key+" ";
		}
		
		public function execute(context:ExecutionContext):*
		{
			
			// this method is not run at parse time.
			// this "execute" method is run at runtime when you define a class
			// note that this method is not run when a new operator happens either
			// rather, this method *defines* the function that will be called when
			// a new happens. See the function definition happens here below.
			
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;
			

			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r defining class " +identifier;
			if (extendedClassName != null) {
			if (processing.DEBUG_FOR_OO) debugTextField.text += " which extends class "+extendedClassName;
			
			}
			
			// define the function that will be called when a new creates a new object
			// e.g. Point point = new Point();

				if (processing.DEBUG_FOR_OO) debugTextField.text += "\r context where the "+ identifier +" constructor is being attached: ";
				if (processing.DEBUG_FOR_OO) context.debug();

			context.scope[identifier] = function (... args)
			{

				if (processing.DEBUG_FOR_OO) debugTextField.text += "\r constructing class " +identifier;
				if (processing.DEBUG_FOR_OO) debugTextField.text += "\r context at start: ";
				if (processing.DEBUG_FOR_OO) context.debug();


				if (dontRunConstructorMethodOrConstructObjects){
					context.dontRunConstructorMethodOrConstructObjects = true;
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r ... without running constructors ";
				}
				else {
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r ... also running constructors ";
				}


				// check that this be called as a constructor
				//[TODO] that
			
				// create new evaluator contexts
				//[TODO] really this should modify .prototype...
				// 1) we create a context for this object so that we add
				//    the variables of the class only to this object we are creating
				var objContext:ExecutionContext = new ExecutionContext(this, context, this);
				objContext.nameOfClassItBelongsTo = identifier;

				// 2) within this object's context, we create a sub-context so that
				//    only the methods invoked from this object can see and use
				//    private variables/methods. Other methods from other objects can't.
				//   (while methods from other objects CAN work on its public variables/methods)
				var classContext:ExecutionContext = new ExecutionContext({}, objContext);
				classContext.nameOfClassItBelongsTo = identifier;
				
				context.recursiveExecutes[identifier](objContext, classContext, extendedClassName,identifier, debugTextField, publicBody, privateBody);
					
				
				// if there us a constructior body that we should run, let's run it.
				// otherwise we'll just keep all the variables and methods that
				// we just attached to the scope.
				
				// there is something that we have to fix here in that
				// we should attach a void function for the empty constructor if there
				// is no constructor. Otherwise it's a mess when someone
				// invokes the empty constructor.
				if (constructorBody && !dontRunConstructorMethodOrConstructObjects) {
				//if (constructorBody) {
					// once we defined all the constructors,
					// here we are invoking the right one.
					// note that we are invoking it with the sub-context, because we don't
					// want to add to the object we are creating all of the temp
					// variables that this constructor methid might be creating.
					// At the same time, if the constructor accesses
					// public variables of the object, those accesses/changes happen
					// in the object context so that they are visible to methods
					// of other objects.
					// How does that happen? It happens because, if you look into the
					// "Reference" class, you see that if a variable is not
					// found in a scope, then the scopes above it are recursively checked.
					// (see Reference.as, the reduce method)
					// so because a public variable is not in the classContext,
					// then the 'objcontext' is checked.
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r class " +identifier +" talking: invoking constructor ";
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r classContext debug: ";
					if (processing.DEBUG_FOR_OO) classContext.debug();
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r classContext scope identifier: " + classContext.scope[identifier];
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r number of arguments: " + args.length;
					classContext.scope[identifier].apply(classContext.scope, args);
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r class " +identifier +" talking: constructor finished ";
				}
				
				// at the end of the actual construction of the object, you can now
				// re-put the flag back that says that you construct objects from now on.
				context.dontRunConstructorMethodOrConstructObjects = false;

			} // end of definition of the funtion that is invoked when a new happens

				if (processing.DEBUG_FOR_OO) debugTextField.text += "\r context after "+ identifier +" constructor has been attached: ";
				if (processing.DEBUG_FOR_OO) context.debug();

		context.recursiveExecutes[identifier] =  function (objContext:ExecutionContext, classContext:ExecutionContext, extendedClassName:String, identifier:String, debugTextField:TextField,publicBody:IExecutable,privateBody:IExecutable):*
		{

			// this should cause the "extends" chain to first be followed up to the top
			// (where the class extends nothing) - then at that point all public/private
			// bodies are executed in the scope of the current object
			// starting from that top class to bottom class down to the class that extends the
			// most classes.
			// This is so that the public and private bodies of the extending classes overwrite
			// the public and private bodies of the extended classes (method overriding).
			// see this: http://en.wikipedia.org/wiki/Method_overriding
			

			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r recursive execute from class " +identifier;
			if (extendedClassName != null) {
				if (processing.DEBUG_FOR_OO) debugTextField.text += "\r recursively invoking executes of class " +extendedClassName;
				context.recursiveExecutes[extendedClassName](objContext, classContext, allClassDefinitions[extendedClassName].extendedClassName,extendedClassName, debugTextField, allClassDefinitions[extendedClassName].publicBody, allClassDefinitions[extendedClassName].privateBody);


			}
			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r class "+identifier+" talking: actually doing the invokations.";

			// this is so that we can give a unique name to each function so that we can
			// invoke super.someMethod( with originalClassNameSomeMethod(
			objContext.nameOfClassItWasOriginallyDefinedIn = identifier;
			classContext.nameOfClassItWasOriginallyDefinedIn = identifier;


			// this piece defines and initializes variables and functions.
			// we run the public body in the public context that anyone can see
			// while we run the private body in the sub-context that only this object can see				
			publicBody.execute(objContext);
			privateBody.execute(classContext);
			
				// OK now we run the constructor body (we don't launch the constructors yet,
				// wee attach all of them in the scope)
				// not that the constructor body might create his own local variables
				// that obviously have to remain in a context inaccessible to other objects,
				// so we tun the body within the sub-context we created above
				// (shouldn't we in theory run it in a sub-su-context though?)
				// OK now we run the constructor body
				// not that the constructor body might create his own loca variables
				// that obviously have to remain in a context inaccessible to other objects,
				// so we tun the body within the sub-context we created above
				// (shouldn't we in theory run it in a sub-su-context though?)
				
				if (constructorBody) {
					//[TODO] look into alternate means of defining constructor?

					// constructorBody is a block of function DEFINITIONS,
					// so what we are doing here is we are first DEFINING all the functions
					// and then we are calling the right one
				
					// defining all the constructor functions (see FunctionDefinition.as)
					constructorBody.execute(classContext);
				}
				else {
					if (processing.DEBUG_FOR_OO) debugTextField.text += "\r there is no constructor body in class "+identifier;
				}


			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r showing the obj context after the invokations";
			if (processing.DEBUG_FOR_OO) objContext.debug();
			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r showing the subcontext after the invokations";
			if (processing.DEBUG_FOR_OO) classContext.debug();
			if (processing.DEBUG_FOR_OO) debugTextField.text += "\r class "+identifier+" talking: done with my bit of the recursive invokations.";

		} // closed function		
	  }
		
	} // closed class
} // close package
