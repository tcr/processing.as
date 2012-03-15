package processing.parser.statements
{
	import processing.parser.*;


	public class Cast implements IExecutable
	{
		public var type:Type;
		public var expression:IExecutable;
	
		public function Cast(t:Type, e:IExecutable) {
			type = t;
			expression = e;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// parse value
			var value:* = expression.execute(context);
			
			// cast non-arrays
			if (!type.dimensions)
			{
				switch (type.type) {
				    case TokenType.VOID:	return void(value);
				    case TokenType.INT:	return int(value);
				    case TokenType.FLOAT:	return Number(value);
				    case TokenType.BOOLEAN:	return Boolean(value);
				    case TokenType.CHAR:	return value is String ? value.charCodeAt(0) : value;
//[TODO] cast objects?
				}
			}
			
			// could not cast
//[TODO] throw error
			return value;
		}
	}
}
