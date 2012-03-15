package processing.parser {
	import flash.utils.describeType;
	import flash.utils.*;
	
	public class TokenType {
		public function TokenType(value:* = '', precedence:int = 0, arity:int = 0, type:int = 0):void {
			_value = value;
			_precedence = precedence;
			_arity = arity;
			_type = type;
		}

		//==============================================================
		// properties
		//==============================================================

		private var _value:* = '';
		public function get value():* { return _value; }

		private var _precedence:int = 0;
		public function get precedence():int { return _precedence; }
		
		private var _arity:int = 0;
		public function get arity():int { return _arity; }
		
		private var _type:int = 0;
		public function get type():int { return _type; }
		
		//==============================================================
		// string functions
		//==============================================================
		
		public function toString():String {
			return _value;
		}
		
		public function valueOf():String {
			return _value;
		}
		
		//==============================================================
		// type constants
		//==============================================================
		
		// get token constant (if one exists)
		public static function getConstant(token:TokenType):String {
			 var description:XML = describeType(TokenType);
			 for each (var constant:XML in description..constant)
				if (TokenType[constant.@name] == token)
					return constant.@name;
			return null;
		}

//[TODO] eliminate these as tokens?
		// EOF
		public static const END:TokenType = new TokenType('END');

		// nonterminal tree node type codes
		public static const SCRIPT:TokenType = new TokenType('SCRIPT');
		public static const BLOCK:TokenType = new TokenType('BLOCK');
		public static const LABEL:TokenType = new TokenType('LABEL');
		public static const FOR_IN:TokenType = new TokenType('FOR_IN');
		public static const CALL:TokenType = new TokenType('CALL', null, 2);
		public static const NEW_WITH_ARGS:TokenType = new TokenType('NEW_WITH_ARGS', null, 2);
		public static const INDEX:TokenType = new TokenType('INDEX', 17, 2);
		public static const ARRAY_INIT:TokenType = new TokenType('ARRAY_INIT', null, 1);
		public static const OBJECT_INIT:TokenType = new TokenType('OBJECT_INIT', null, 1);
		public static const PROPERTY_INIT:TokenType = new TokenType('PROPERTY_INIT');
		public static const GROUP:TokenType = new TokenType('GROUP', null, 1);
		public static const LIST:TokenType = new TokenType('LIST');
		
		// ...something
		public static const CONSTRUCTOR:TokenType = new TokenType('CONSTRUCTOR');
		
		// terminals
		public static const IDENTIFIER:TokenType = new TokenType('IDENTIFIER');
		public static const TYPE:TokenType = new TokenType('TYPE');
		public static const NUMBER:TokenType = new TokenType('NUMBER');
		public static const STRING:TokenType = new TokenType('STRING');
		public static const REGEXP:TokenType = new TokenType('REGEXP');
		public static const ARRAY_DIMENSION:TokenType = new TokenType('[]');
	
		// operators
		public static const NEWLINE:TokenType = new TokenType('\n');
		public static const SEMICOLON:TokenType = new TokenType(';', 0);
		public static const COMMA:TokenType = new TokenType(',', 1, -2);
		public static const HOOK:TokenType = new TokenType('?', 2);
		public static const COLON:TokenType = new TokenType(':', 2);
		public static const OR:TokenType = new TokenType('||', 4, 2);
		public static const AND:TokenType = new TokenType('&&', 5, 2);
		public static const BITWISE_OR:TokenType = new TokenType('|', 6, 2);
		public static const BITWISE_XOR:TokenType = new TokenType('^', 7, 2);
		public static const BITWISE_AND:TokenType = new TokenType('&', 8, 2);
		public static const STRICT_EQ:TokenType = new TokenType('===', 9, 2);
		public static const EQ:TokenType = new TokenType('==', 9, 2);
		public static const ASSIGN:TokenType = new TokenType('=', 2, 2);
		public static const STRICT_NE:TokenType = new TokenType('!==', 9, 2);
		public static const NE:TokenType = new TokenType('!=', 9, 2);
		public static const LSH:TokenType = new TokenType('<<', 11, 2);
		public static const LE:TokenType = new TokenType('<=', 10, 2);
		public static const LT:TokenType = new TokenType('<', 10, 2);
		public static const URSH:TokenType = new TokenType('>>>', 11, 2);
		public static const RSH:TokenType = new TokenType('>>', 11, 2);
		public static const GE:TokenType = new TokenType('>=', 10, 2);
		public static const GT:TokenType = new TokenType('>', 10, 2);
		public static const INCREMENT:TokenType = new TokenType('++', 15, 1);
		public static const DECREMENT:TokenType = new TokenType('--', 15, 1);
		public static const PLUS:TokenType = new TokenType('+', 12, 2);
		public static const MINUS:TokenType = new TokenType('-', 12, 2);
		public static const MUL:TokenType = new TokenType('*', 13, 2);
		public static const DIV:TokenType = new TokenType('/', 13, 2);
		public static const MOD:TokenType = new TokenType('%', 13, 2);
		public static const NOT:TokenType = new TokenType('!', 14, 1);
		public static const BITWISE_NOT:TokenType = new TokenType('~', 14, 1);
		public static const DOT:TokenType = new TokenType('.', 17, 2);
		public static const LEFT_BRACKET:TokenType = new TokenType('[');
		public static const RIGHT_BRACKET:TokenType = new TokenType(']');
		public static const LEFT_CURLY:TokenType = new TokenType('{');
		public static const RIGHT_CURLY:TokenType = new TokenType('}');
		public static const LEFT_PAREN:TokenType = new TokenType('(');
		public static const RIGHT_PAREN:TokenType = new TokenType(')');
		public static const CONDITIONAL:TokenType = new TokenType('CONDITIONAL', 2, 3);
		public static const UNARY_PLUS:TokenType = new TokenType('UNARY_PLUS', 14, 1);
		public static const UNARY_MINUS:TokenType = new TokenType('UNARY_MINUS', 14, 1);
		public static const CAST:TokenType = new TokenType('CAST', 14, 2);

		public static const OPS:Object = {
			'\n':	NEWLINE,
			';':	SEMICOLON,
			',':	COMMA,
			'?':	HOOK,
			':':	COLON,
			'||':	OR,
			'&&':	AND,
			'|':	BITWISE_OR,
			'^':	BITWISE_XOR,
			'&':	BITWISE_AND,
			'===':	STRICT_EQ,
			'==':	EQ,
			'=':	ASSIGN,
			'!==':	STRICT_NE,
			'!=':	NE,
			'<<':	LSH,
			'<=':	LE,
			'<':	LT,
			'>>>':	URSH,
			'>>':	RSH,
			'>=':	GE,
			'>':	GT,
			'++':	INCREMENT,
			'--':	DECREMENT,
			'+':	PLUS,
			'-':	MINUS,
			'*':	MUL,
			'/':	DIV,
			'%':	MOD,
			'!':	NOT,
			'~':	BITWISE_NOT,
			'.':	DOT,
			'[':	LEFT_BRACKET,
			']':	RIGHT_BRACKET,
			'{':	LEFT_CURLY,
			'}':	RIGHT_CURLY,
			'(':	LEFT_PAREN,
			')':	RIGHT_PAREN
		    };
		    
		public static const ASSIGNMENT_OPS:Object = {
			'|':	BITWISE_OR,
			'^':	BITWISE_XOR,
			'&':	BITWISE_AND,
			'<<':	LSH,
			'>>>':	URSH,
			'>>':	RSH,
			'+':	PLUS,
			'-':	MINUS,
			'*':	MUL,
			'/':	DIV,
			'%':	MOD
		    };
		
		// keywords
		public static const BREAK:TokenType = new TokenType();
		public static const CLASS:TokenType = new TokenType();
		public static const CLASSNOTINVOKINGCONSTRUCTORS:TokenType = new TokenType();
		public static const CASE:TokenType = new TokenType();
		public static const CATCH:TokenType = new TokenType();
		public static const CONST:TokenType = new TokenType();
		public static const CONTINUE:TokenType = new TokenType();
		public static const DEBUGGER:TokenType = new TokenType();
		public static const DEFAULT:TokenType = new TokenType();
		public static const DELETE:TokenType = new TokenType('delete', 14, 1);
		public static const DO:TokenType = new TokenType();
		public static const ELSE:TokenType = new TokenType();
		public static const ENUM:TokenType = new TokenType();
		public static const EXTENDS:TokenType = new TokenType('extends');
		public static const FALSE:TokenType = new TokenType(false);
		public static const FINALLY:TokenType = new TokenType();
		public static const FOR:TokenType = new TokenType();
		public static const FUNCTION:TokenType = new TokenType();
		public static const IF:TokenType = new TokenType();
		public static const IN:TokenType = new TokenType('in', 10, 2);
		public static const INSTANCEOF:TokenType = new TokenType('instanceof', 10, 2);
		public static const NEW:TokenType = new TokenType('new', 16, 1);
		public static const NULL:TokenType = new TokenType(null);
		public static const PUBLIC:TokenType = new TokenType('public');
		public static const PRIVATE:TokenType = new TokenType('private');
		public static const RETURN:TokenType = new TokenType();
		public static const STATIC:TokenType = new TokenType('static');
		public static const SWITCH:TokenType = new TokenType();
		public static const THIS:TokenType = new TokenType();
		public static const THROW:TokenType = new TokenType();
		public static const TRUE:TokenType = new TokenType(true);
		public static const TRY:TokenType = new TokenType();
		public static const TYPEOF:TokenType = new TokenType('typeof', 14, 1);
		public static const VAR:TokenType = new TokenType();
		public static const WHILE:TokenType = new TokenType();
		public static const WITH:TokenType = new TokenType();
		
// can trip on KEYWORDS[toString]...!
		public static const KEYWORDS:Object = {
			'break':	BREAK,
			'class':	CLASS,
			'PROCESSINGASRESERVEDKEYWORDclassnotinvokingconstructors':	CLASSNOTINVOKINGCONSTRUCTORS,
			'case':		CASE,
			'catch':	CATCH,
			'const':	CONST,
			'continue':	CONTINUE,
			'debugger':	DEBUGGER,
			'default':	DEFAULT,
			'delete':	DELETE,
			'do':		DO,
			'else':		ELSE,
			'enum':		ENUM,
			'extends':	EXTENDS,
			'false':	FALSE,
			'finally':	FINALLY,
			'for':		FOR,
			'function':	FUNCTION,
			'if':		IF,
			'in':		IN,
			'instanceof':	INSTANCEOF,
			'new':		NEW,
			'null':		NULL,
			'public':	PUBLIC,
			'private':	PRIVATE,
			'return':	RETURN,
			'static':	STATIC,
			'switch':	SWITCH,
			'this':		THIS,
			'throw':	THROW,
			'true':		TRUE,
			'try':		TRY,
			'typeof':	TYPEOF,
			'var':		VAR,
			'while':	WHILE,
			'with':		WITH
		    };
		    
		// variable types
		public static const VOID:TokenType = new TokenType('void');
		public static const BOOLEAN:TokenType = new TokenType('boolean');
		public static const FLOAT:TokenType = new TokenType('float');
		public static const INT:TokenType = new TokenType('int');
		public static const CHAR:TokenType = new TokenType('char');
		    
		public static const TYPES:Object = {
			'boolean':	BOOLEAN,
			'char':		CHAR,
			'void':		VOID,			
			'float':	FLOAT,
			'int':		INT
		    };
		    
		// function constants
//[TODO] move these elsewhere!
		public static const FUNCTION_DECLARED_FORM:Object = new Object();
		public static const FUNCTION_EXPRESSED_FORM:Object = new Object();
		public static const FUNCTION_STATEMENT_FORM:Object = new Object();
	}
}
