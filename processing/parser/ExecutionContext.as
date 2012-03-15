package processing.parser
{	
	public class ExecutionContext
	{
//[TODO] rename this to Scope class?
		public var scope:Object = {};
		public var recursiveExecutes:Object = {};
		public var parent:ExecutionContext;
		public var thisObject:Object = null;
		public var nameOfClassItBelongsTo:String = null;
		public var nameOfClassItWasOriginallyDefinedIn:String = null;
		public var dontRunConstructorMethodOrConstructObjects:Boolean = false;

//		public var caller;
//		public var callee;
//		public var result = undefined;
//		public var target = null;

		public function ExecutionContext(s:Object = null, p:ExecutionContext = null, t:Object = null):void
		{
			scope = s || {};
			parent = p;
			thisObject = t;
			
			if (p != null){
				this.dontRunConstructorMethodOrConstructObjects = p.dontRunConstructorMethodOrConstructObjects;
			}
			else {
				this.dontRunConstructorMethodOrConstructObjects = false;
			}
		}
		
		public function debug():void
		{


			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += " \n Context debug: ";
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += " \n    In class: " + nameOfClassItBelongsTo;
			if (processing.DEBUG_FOR_OO) processing.debugTextField.text += " \n    dont Run Constructor Method Or Construct Objects: " + dontRunConstructorMethodOrConstructObjects;

			for (var key in scope){
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\n    "+key;
			
			}
			if (parent != null){
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\n   -->goingupthecontextnow! ";
				if (processing.DEBUG_FOR_OO) parent.debug();
			}

		}

	}
}
