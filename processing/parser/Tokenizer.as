package processing.parser {
	import processing.parser.*;
	
//[TODO] might want to take cues from a real Tokenizer class....
	public class Tokenizer {
		public var source:String = '';
		public var cursor:int = 0;
		public var line:int = 1;
		public var scanOperand:Boolean = true;
		
		public function Tokenizer(s:String = '', l:int = 1):void {
			source = s;
			line = l;
		}
		
		public function load(s:String = '', l:int = 1) {
			// load source and reset location
			source = s;
			cursor = 0;
			line = l;
			scanOperand = true;
		}
		
		public function peek(lookAhead:int = 1, onSameLine:Boolean = false):Token {
			// init variables
			var peekCursor:Number = cursor, peekLine:Number = line;
			for (var token:Token; lookAhead; lookAhead--) {
				while (true) {
					// eliminate whitespace
					var input = source.substring(peekCursor);
					var match = (onSameLine ? /^[ \t]+/ : /^\s+/)(input);
					if (match) {
						var spaces = match[0];
						peekCursor += spaces.length;
						if (spaces.match(/\n/))
							peekLine += spaces.match(/\n/g).length;
						input = source.substring(peekCursor);
					}
			
					// eliminate comments
					if (!(match = /^\/(?:\*(?:.|\n|\r)*?\*\/|\/.*)/(input)))
						break;
					var comment = match[0];
					peekCursor += comment.length;
					if (comment.match(/\n/))
						peekLine += comment.match(/\n/g).length;
				}
							
				// find next token
				if ((match = /^$/(input)))
				{
					// end
					token = new Token(TokenType.END);
				}
				else if ((match = /^(?:0[xX]|#)([\da-fA-F]{6}|[\da-fA-F]{8})/(input)))
				{
					// color
					token = new Token(TokenType.NUMBER, parseInt('0x' + match[1]) + (match[1].length == 6 ? 0xFF000000 : 0));
				}
				else if ((match = /^\d+(?:\.\d*)?[fF]|^\d+\.\d*(?:[eE][-+]?\d+)?|^\d+(?:\.\d*)?[eE][-+]?\d+|^\.\d+(?:[eE][-+]?\d+)?/(input)))
				{
					// float
					token = new Token(TokenType.NUMBER, parseFloat(match[0]));
				}
				else if ((match = /^0[xX][\da-fA-F]+|^0[0-7]*|^\d+/(input)))
				{
					// integer
					token = new Token(TokenType.NUMBER, parseInt(match[0]));
				}
				else if ((match = /^\w+/(input)))
				{
					// type
					if (match[0] in TokenType.TYPES)
						token = new Token(TokenType.TYPE, TokenType.TYPES[match[0]]);
					// keyword
					else if (match[0] in TokenType.KEYWORDS)
						token = new Token(TokenType.KEYWORDS[match[0]], TokenType.KEYWORDS[match[0]].value);
						
					// identifier
					else
						token = new Token(TokenType.IDENTIFIER, match[0]);
				}
				else if ((match = /^(?:\[\]){1,3}/(input)))
				{
					// array dimensions
					token = new Token(TokenType.ARRAY_DIMENSION, match[0].length / 2);
				}
				else if ((match = /^'(?:[^']|\\.|\\u[0-9A-Fa-f]{4})'/(input)))
				{
					// char
					token = new Token(TokenType.CHAR, parseStringLiteral(match[0].substring(1, match[0].length - 1)).charCodeAt(0));
				}
				else if ((match = /^"(?:\\.|[^"])*"|^'(?:[^']|\\.)*'/(input)))
				{
					// string
					token = new Token(TokenType.STRING, parseStringLiteral(match[0].substring(1, match[0].length - 1)));
				}
				else if ((match = /^(\n|\|\||&&|===?|!==?|<<|<=|>>>?|>=|\+\+|--|\[\]|[;,?:|^&=<>+\-*\/%!~.[\]{}()])/(input)))
				{
					// operator
					var op:String = match[0];
					if (TokenType.ASSIGNMENT_OPS[op] && input.charAt(op.length) == '=') {
						token = new Token(TokenType.ASSIGN, op);
						token.assignOp = TokenType.OPS[op];
						match[0] += '=';
					} else {
						token = new Token(TokenType.OPS[op], op);
						if (scanOperand) {
							if (token.type == TokenType.PLUS)
								token.type = TokenType.UNARY_PLUS;
							if (token.type == TokenType.MINUS)
								token.type = TokenType.UNARY_MINUS;
						}
						token.assignOp = null;
					}
				}
				else
				{
					throw new TokenizerSyntaxError('Illegal token ' + input, this);
				}
		
				// set token properties
				token.content = match[0];
				token.start = peekCursor;
				token.line = peekLine;
				
				// move cursor
				peekCursor += token.content.length;
			}
			
			return token;
		}
		
		private function parseStringLiteral(str:String):String {
			return str
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\b/g, '$1\u0008')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\t/g, '$1\u0009')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\n/g, '$1\u000A')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\v/g, '$1\u000B')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\f/g, '$1\u000C')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\r/g, '$1\u000D')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\r/g, '$1\u000D')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\"/g, '$1"')
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\'/g, "$1'")
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\u([0-9A-Fa-z]{4})/g,
				function (str:String, opening:String, code:String):String {
					return opening + String.fromCharCode(parseInt(code, 16));
				})
			    .replace(/((?:[^\\]|^)(?:\\\\)+)\\\\/g, '\\');
		}
		
		public var _currentToken:Token;
		public function get currentToken() { return _currentToken; }
	
		public function get():Token {
			// get next token
			_currentToken = peek();
			// move variables
			cursor = currentToken.start + currentToken.content.length;
			line = currentToken.line;
			return currentToken;
		}
		
		public function match(matchType:TokenType, mustMatch:Boolean = false):Boolean {
			var doesMatch:Boolean = (peek().type == matchType);
			if (doesMatch)
				get();
			else if (mustMatch)
				throw new TokenizerSyntaxError('Missing ' + TokenType.getConstant(matchType), this);
			return doesMatch;
		}
		
		public function get done():Boolean {
			return match(TokenType.END);
		}
	}
}
