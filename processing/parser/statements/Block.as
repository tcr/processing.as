package processing.parser.statements
{
	import processing.parser.*;

	dynamic public class Block extends Array implements IExecutable
	{

		public function Block(... statements):void
		{
			for each (var statement:IExecutable in statements)
				push(statement);
		}
		
		public function append(block:Block)
		{
			// perform permanent concatenation
			for each (var statement:IExecutable in block)
				push(statement);
			return length;
		}

		public function execute(context:ExecutionContext)
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// iterate block
			var retValue:*;
			for each (var statement:IExecutable in this){
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r running this statement: " + statement;
				if (processing.DEBUG_FOR_OO) context.debug();
				retValue = statement.execute(context);
			}
			return retValue;
		}


	}
}
