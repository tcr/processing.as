package processing.parser.statements
{
	import processing.parser.*;


	public class Operation implements IExecutable
	{
		public var type:TokenType;
		public var leftOperand:IExecutable;
		public var rightOperand:IExecutable;
	
		public function Operation(t:TokenType, l:IExecutable, r:IExecutable = null)
		{
			type = t;
			leftOperand = l;
			rightOperand = r;
		}
	
		public function execute(context:ExecutionContext):*
		{
			// we prevent any other instruction to happen if the haltExecution flag is set
			if (processing.haltExecution) return;

			// evaluate operands
			var a:* = leftOperand.execute(context);
			if (rightOperand)
				var b:* = rightOperand.execute(context);

			// evaluate operation
			switch (type) {
			    // unary operators
			    case TokenType.NOT:		return !a;
			    case TokenType.BITWISE_NOT:	return ~a;
			    case TokenType.UNARY_PLUS:		return +a;
			    case TokenType.UNARY_MINUS:	return -a;

			    // binary operators
			    case TokenType.OR:			return a || b;
			    case TokenType.AND:		return a && b;
			    case TokenType.BITWISE_OR:		return a | b;
			    case TokenType.BITWISE_XOR:	return a ^ b;
			    case TokenType.BITWISE_AND:	return a & b;
			    case TokenType.EQ:			return a == b;
			    case TokenType.NE:			return a != b;
			    case TokenType.STRICT_EQ:		return a === b;
			    case TokenType.STRICT_NE:		return a !== b;
			    case TokenType.LT:			return a < b;
			    case TokenType.LE:			return a <= b;
			    case TokenType.GT:			return a > b;
			    case TokenType.GE:			return a >= b;
			    case TokenType.IN:			return a in b;
			    case TokenType.INSTANCEOF:		return a instanceof b;
			    case TokenType.LSH:		return a << b;
			    case TokenType.RSH:		return a >> b;
			    case TokenType.URSH:		return a >>> b;
			    case TokenType.PLUS:		return a + b;
			    case TokenType.MINUS:		return a - b;
			    case TokenType.MUL:		return a * b;
			    case TokenType.DIV:		return a / b;
			    case TokenType.MOD:		return a % b;
			    case TokenType.DOT:		return a[b];
			    default: throw new Error('Unrecognized expression operator.');
			}
		}
	}
}
