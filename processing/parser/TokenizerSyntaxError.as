package processing.parser {
	import processing.parser.Tokenizer;

	public class TokenizerSyntaxError extends SyntaxError {
		public var source:String = '';
		public var line:int = 0;
		public var cursor:Number = 0;
		
		public function TokenizerSyntaxError(message:String = '', tokenizer:Tokenizer = null) {
			if (tokenizer) {
				source = tokenizer.source;
				line = tokenizer.line;
				cursor = tokenizer.cursor;
				
				message += '\nParsing error (line ' + line + ', char ' + cursor + ')';
			}
			
			super(message);
		}
	}
}