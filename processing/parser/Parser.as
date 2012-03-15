package processing.parser {
	import processing.parser.*;
	import processing.parser.statements.*;
	
	public class Parser {
		public var tokenizer:Tokenizer;
//[TODO] no parser contexts; but maybe add a Block.definitions array?
//		public var context:ParserContext;
	
		public function Parser() {
			// create tokenizer
			tokenizer = new Tokenizer();
		}
		
		public function parse(code:String):Block {
			// initialize tokenizer
			tokenizer.load(replaceSupers(code));
			
			// parse script
			var script:Block = parseBlock();
			if (!tokenizer.done)
				throw new TokenizerSyntaxError('Syntax error', tokenizer);
			return script;
		}

		private function replaceSupers(code:String):String {

			var firstSuper;
			var lasteExtendsBeforeFirstSuper;
			var classStartBracket;
			var findingTheExtendedClass;
			var extendingClassName;
			var lasteClassBeforeFirstSuper;

			while ((firstSuper = code.indexOf("super(")) != -1){
				//firstSuper = code.indexOf("super(");
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r found a super( at char " + firstSuper;
				lasteExtendsBeforeFirstSuper= code.lastIndexOf("extends", firstSuper);
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r the previous extends is at char " + lasteExtendsBeforeFirstSuper;
				classStartBracket= code.indexOf("{", lasteExtendsBeforeFirstSuper+7);
				findingTheExtendedClass = code.slice(lasteExtendsBeforeFirstSuper+7,classStartBracket).replace(/\s+/g,"");
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r the name of the extended class is " + findingTheExtendedClass;
				code = code.slice(0,firstSuper)+findingTheExtendedClass+"("+code.slice(firstSuper+6);
			}

				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r diced super( " + code;
			
			while ((firstSuper = code.indexOf("super.")) != -1){
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r found a super. at char " + firstSuper;
				lasteExtendsBeforeFirstSuper= code.lastIndexOf("extends", firstSuper);
				lasteClassBeforeFirstSuper= code.lastIndexOf("class", firstSuper);
				extendingClassName = code.slice(lasteClassBeforeFirstSuper+5, lasteExtendsBeforeFirstSuper).replace(/\s+/g,"");
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r the previous extends is at char " + lasteExtendsBeforeFirstSuper;
				classStartBracket= code.indexOf("{", lasteExtendsBeforeFirstSuper+7);
				findingTheExtendedClass = code.slice(lasteExtendsBeforeFirstSuper+7,classStartBracket).replace(/\s+/g,"");
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r the name of the extended class is " + findingTheExtendedClass;
				code = code.slice(0,firstSuper)+"OverloadFor"+extendingClassName+findingTheExtendedClass+code.slice(firstSuper+6);
			}

				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r diced super. " + code;
			
			return code;
			
		}
		
		private function parseBlock(stopAt:TokenType = null):Block {
			// parse code block
			var block:Block = new Block();
//[TODO] right_curly should be a stopAt
			while (!tokenizer.done && (!stopAt || !tokenizer.peek().match(stopAt)))
				block.append(parseStatement());
			return block;			
		}

//[TODO] could parseStatement be made to only match certain "types"?
		private function parseStatement():Block {
			// parse current statement line
			var block:Block = new Block();

			// peek to see what kind of statement this is
			var token:Token = tokenizer.peek();
//trace('Currently parsing in Statement: ' + TokenType.getConstant(token.type));
			switch (token.type)
			{				
			    // if block
			    case TokenType.IF:
				// get condition
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				var condition:IExecutable = parseExpression();
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// get then block
				if (tokenizer.match(TokenType.LEFT_CURLY)) {
					var thenBlock:Block = parseBlock(TokenType.RIGHT_CURLY);
					tokenizer.match(TokenType.RIGHT_CURLY, true);
				} else
					var thenBlock:Block = parseStatement();
				// get else block
				if (tokenizer.match(TokenType.ELSE)) {
					if (tokenizer.match(TokenType.LEFT_CURLY)) {
						var elseBlock:Block = parseBlock(TokenType.RIGHT_CURLY);
						tokenizer.match(TokenType.RIGHT_CURLY, true);
					} else
						var elseBlock:Block = parseStatement();
				}
				
				// push conditional
				block.push(new Conditional(condition, thenBlock, elseBlock));
				return block;
				
			    // while statement
			    case TokenType.WHILE:
				// match opening 'for' and '('
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				
				// match condition
				var condition:IExecutable = parseExpression(TokenType.RIGHT_PAREN);
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// parse body
				if (tokenizer.match(TokenType.LEFT_CURLY)) {
					var body:Block = parseBlock(TokenType.RIGHT_CURLY);
					tokenizer.match(TokenType.RIGHT_CURLY, true);
				} else
					var body:Block = parseStatement();

				// push for loop
				block.push(new Loop(condition, body));
				return block;

			    ///////////////////
			    // switch statement
			    ///////////////////
			    var CLASSNOTINVOKINGCONSTRUCTORS:Boolean = false;
			    case TokenType.SWITCH:
					// match opening 'for' and '('
					tokenizer.get();
					tokenizer.match(TokenType.LEFT_PAREN, true);
				
					block.push(parseExpression(TokenType.SEMICOLON));
						
					// match semicolon
					tokenizer.match(TokenType.SEMICOLON, true);
					
					//so far so good
				
					return block;

			    // for statement
			    case TokenType.FOR:
				// match opening 'for' and '('
				tokenizer.get();
				tokenizer.match(TokenType.LEFT_PAREN, true);
				
				// match initializer
				if (!tokenizer.match(TokenType.SEMICOLON)) {
					// variable definitions
					if ((tokenizer.peek().match(TokenType.TYPE) ||
					    tokenizer.peek().match(TokenType.IDENTIFIER)) &&
					    tokenizer.peek(2).match(TokenType.IDENTIFIER))
					    	block.append(parseVariables());
					// expression
					else
						block.push(parseExpression(TokenType.SEMICOLON));
						
					// match semicolon
					tokenizer.match(TokenType.SEMICOLON, true);
				}
				
				// match condition
				var condition:IExecutable = parseExpression(TokenType.SEMICOLON);
				tokenizer.match(TokenType.SEMICOLON, true);
				// match update
				var update:IExecutable = parseExpression(TokenType.RIGHT_PAREN);
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				// parse body
				if (tokenizer.match(TokenType.LEFT_CURLY)) {
					var body:Block = parseBlock(TokenType.RIGHT_CURLY);
					tokenizer.match(TokenType.RIGHT_CURLY, true);
				} else
					var body:Block = parseStatement();
				
				// append loop body
				if (update)
					body.push(update);
				// push for loop
				block.push(new Loop(condition, body));
				return block;
			
			    // returns
			    case TokenType.RETURN:
				tokenizer.get();
				// push return statement
				if (!tokenizer.peek().match(TokenType.SEMICOLON)){
					//processing.debugTextField.text += "\r parsed return with value";
					block.push(new Return(parseExpression()));
				}
				else {
					//processing.debugTextField.text += "\r parsed empty return";
					
					// this is a bit of a hack because a return with no value
					// should return a no-value
					// but I think that this works almost the same.
					block.push(new Return(new Literal('0')));
				}
				break;
			
			    // break
			    case TokenType.BREAK:
				tokenizer.get();			
				// match break and optional level
				block.push(new Break(tokenizer.match(TokenType.NUMBER) ?
				    tokenizer.currentToken.value : 1));					
				break;
				
			    // continue
			    case TokenType.CONTINUE:
				tokenizer.get();			
				// match continue and optional level
				block.push(new Continue(tokenizer.match(TokenType.NUMBER) ?
				    tokenizer.currentToken.value : 1));					
				break;
				
			    // definition visibility
			    case TokenType.STATIC:
			    case TokenType.PUBLIC:
			    case TokenType.PRIVATE:
//[TODO] what happens when "private" declared in main block? "static"?
				// get definition
				tokenizer.get();
				block.push(tokenizer.peek().match(TokenType.CLASS) ? parseClass(false) : parseFunction());
				return block;
				
			    case TokenType.CLASSNOTINVOKINGCONSTRUCTORS:
			    CLASSNOTINVOKINGCONSTRUCTORS = true;
			    
			    case TokenType.CLASS:
				// get class definition
				if (CLASSNOTINVOKINGCONSTRUCTORS) {
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r parsing a class that doesn't invoke constructors";
				}
				else {
					if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r parsing a class that does invoke constructors";
				}
				block.push(parseClass(CLASSNOTINVOKINGCONSTRUCTORS));
				//block.push(parseClass(false));
				return block;
			
			    // definitions
			    case TokenType.TYPE:
			    case TokenType.IDENTIFIER:
				// resolve ambiguous identifier
				var isArray:Boolean = tokenizer.peek(2).match(TokenType.ARRAY_DIMENSION);
				if (tokenizer.peek(2 + isArray).match(TokenType.IDENTIFIER)) {
					// get parsed function
					if (tokenizer.peek(3 + isArray).match(TokenType.LEFT_PAREN))
						return new Block(parseFunction());
						
					// else, get variable list
					block.append(parseVariables());
					break;
				}
				// fall-through
			
			    // expression
			    default:
				block.push(parseExpression(TokenType.SEMICOLON));
				break;
			}

			// match terminating semicolon
			if (!tokenizer.match(TokenType.SEMICOLON))
				throw new TokenizerSyntaxError('Missing ; after statement', tokenizer);
			// return parsed statement
			return block;
		}
		
		private function parseType():Type {
			// try and match a type declaration
			if (!tokenizer.match(TokenType.TYPE) && !tokenizer.match(TokenType.IDENTIFIER))
				return null;
				
			// return type declaration
			var type:* = tokenizer.currentToken.value;
			var dimensions:int = tokenizer.match(TokenType.ARRAY_DIMENSION) ? tokenizer.currentToken.value : 0;
			return new Type(type, dimensions);
		}
		
		private function parseFunction():FunctionDefinition {
			// get function type (if not constructor)
			if (!tokenizer.peek(2).match(TokenType.LEFT_PAREN))
				var funcType:Type = parseType();
			// get function name
			tokenizer.match(TokenType.IDENTIFIER, true);
			var funcName:String = tokenizer.currentToken.value;
			processing.functionNamesmyArray[processing.functionNamesmyArray.length] = funcName;
			
			// parse parameters
			tokenizer.match(TokenType.LEFT_PAREN, true);
			var params:Array = [];
			while (!tokenizer.peek().match(TokenType.RIGHT_PAREN))
			{
				// get type
				var type:Type = parseType();
				if (!type)
					throw new TokenizerSyntaxError('Invalid formal parameter type', tokenizer);
				// get identifier
				if (!tokenizer.match(TokenType.IDENTIFIER))
					throw new TokenizerSyntaxError('Invalid formal parameter', tokenizer);
				var name:String = tokenizer.currentToken.value;
				
				// add parameter
				params.push([name, type]);
				
				// check for comma
				if (!tokenizer.peek().match(TokenType.RIGHT_PAREN))
					tokenizer.match(TokenType.COMMA, true);
			}
			tokenizer.match(TokenType.RIGHT_PAREN, true);
			
			// parse body
			tokenizer.match(TokenType.LEFT_CURLY, true);
			var body:Block = parseBlock(TokenType.RIGHT_CURLY);
			tokenizer.match(TokenType.RIGHT_CURLY, true);
			
			// return function declaration statement
			return new FunctionDefinition(funcName, funcType, params, body);
		}
		
		private function parseClass(NOTINVOKINGCONSTRUCTORS:Boolean):ClassDefinition
		{
			// get class name
			
			if(!NOTINVOKINGCONSTRUCTORS) {
				tokenizer.match(TokenType.CLASS, true);
			}
			else {
				tokenizer.match(TokenType.CLASSNOTINVOKINGCONSTRUCTORS, true);
			}
			
			tokenizer.match(TokenType.IDENTIFIER, true);
			var className:String = tokenizer.currentToken.value;
			
			
			// *****************************************
			// checking classes extending other classes
			// *****************************************
			//
			// here is the processing language reference page for "extends" - it also
			// includes an example that you can use for testing.
			// http://processing.org/reference/extends.html
			//
			// this variable will contain the name of the class that we are extending
			// note that it contains ONE class name - as in java you can
			// only extend one class - java doesn't do multiple
			// inheritance.
			var extendedClassName:String = null;
			
			//processing.debugTextField.text += "\r parsing a class ";
			//processing.debugTextField.text += "\r tokenizer peek 1 " + tokenizer.peek(1).value + " of type " + TokenType.getConstant(tokenizer.peek(1).type);
			//processing.debugTextField.text += "\r tokenizer peek 2 " + tokenizer.peek(2).value + " of type " + TokenType.getConstant(tokenizer.peek(2).type);
			//processing.debugTextField.text += "\r tokenizer peek 3 " + tokenizer.peek(3).value + " of type " + TokenType.getConstant(tokenizer.peek(3).type);
			if (tokenizer.peek(1).match(TokenType.EXTENDS) && tokenizer.peek(2).match(TokenType.IDENTIFIER) && tokenizer.peek(3).match(TokenType.LEFT_CURLY) ) {
				extendedClassName = tokenizer.peek(2).value;
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r class "+ className +" extends class " + extendedClassName;
				tokenizer.get();
				tokenizer.get();
			}
			else {
				if (processing.DEBUG_FOR_OO) processing.debugTextField.text += "\r class "+ className +" doesn't extend any other class ";
			}
			// *****************************************
			
			
			
			// parse body
			var constructor:Block = new Block();
			var publicBody:Block = new Block(), privateBody:Block = new Block();
			tokenizer.match(TokenType.LEFT_CURLY, true);
			while (!tokenizer.peek().match(TokenType.RIGHT_CURLY))
			{
				// get visibility (default public)
				var block:Block = publicBody;
				tokenizer.match(TokenType.PUBLIC);
				if (tokenizer.match(TokenType.PRIVATE))
				        block = privateBody;

				// get next token
				var token:Token = tokenizer.peek();
				switch (token.type)
				{
				    // variable or function
				    case TokenType.IDENTIFIER:
					// check for constructor
					if (token.value == className && tokenizer.peek(2).match(TokenType.LEFT_PAREN) )
					{
											
						// get type-less constructors
						constructor.push(parseFunction());
						break;
					}
					// case type; fall-through
					
				    case TokenType.TYPE:
					if (tokenizer.peek(2).match(TokenType.IDENTIFIER) ||
					    tokenizer.peek(2).match(TokenType.ARRAY_DIMENSION))
					{
						// parse definition. Note that we could be parsing a function here.
						block.append(parseStatement());
						break;
					}
					// invalid definition; fall-through
				    
				    default:
					throw new TokenizerSyntaxError('Invalid initializer in class "' + className + '"', tokenizer);
				}
			}
			tokenizer.match(TokenType.RIGHT_CURLY, true);
			
			// return class declaration statement
			return new ClassDefinition(className, extendedClassName, constructor, publicBody, privateBody, processing.debugTextField, NOTINVOKINGCONSTRUCTORS);
		}
		
		private function parseVariables():Block
		{
			// get main variable type
			var declarationType:Type = parseType();
			// get variable list
			var block:Block = new Block();
			do {
				// add definitions
				tokenizer.match(TokenType.IDENTIFIER, true);
				var varName:String = tokenizer.currentToken.value;
				// check for per-variable array brackets
				var varDimensions:int = tokenizer.match(TokenType.ARRAY_DIMENSION) ?
				    tokenizer.currentToken.value : declarationType.dimensions;
				// add definition
				block.push(new VariableDefinition(varName, new Type(declarationType.type, varDimensions)));
				
				// check for assignment operation
				if (tokenizer.match(TokenType.ASSIGN))
				{
					// prevent assignment operators like +,-,... (not the equal, that's fine)
					if (tokenizer.currentToken.assignOp) {
						throw new TokenizerSyntaxError('Invalid variable initialization', tokenizer);
					}

					// get initializer statement
					block.push(new Assignment(new Reference(new Literal(varName)),
					    parseExpression(TokenType.COMMA)));
				}
			} while (tokenizer.match(TokenType.COMMA));
			
			// return variable definition
			return block;
		}
		
//[TODO] remove stopAt token altogether
		private function parseList(stopAt:TokenType):Array
		{
			// parse a list (array initializer, function call, &c.)
			var list:Array = [];
			while (!tokenizer.peek().match(stopAt)) {
				// parse empty entries
				if (tokenizer.match(TokenType.COMMA)) {
					list.push(null);
					continue;
				}
				// parse arguments up to next comma
				list.push(parseExpression(TokenType.COMMA));
				if (!tokenizer.match(TokenType.COMMA))
					break;
			}
			return list;
		}
		
		private function parseExpression(stopAt:TokenType = undefined):IExecutable
		{
			// variable definitions
			var operators:Array = [], operands:Array = [];
		
			// main loop
			if (scanOperand(operators, operands, stopAt))
				while (scanOperator(operators, operands, stopAt))
					scanOperand(operators, operands, stopAt, true);
				
			// reduce to a single operand
			while (operators.length)
				reduceExpression(operators, operands);
			return operands.pop();
		}

		private function scanOperand(operators:Array, operands:Array, stopAt:TokenType = null, required:Boolean = false):Boolean
		{
			// get next token
			tokenizer.scanOperand = true;
			var token:Token = tokenizer.peek();
			// stop if token matches stop parameter
			if (stopAt && token.match(stopAt))
				return false;

			// switch based on type
			switch (token.type)
			{			
			    // unary operators
			    case TokenType.INCREMENT:
			    case TokenType.DECREMENT:
//[TODO] which of these are used in processing?
			    case TokenType.DELETE:
			    case TokenType.TYPEOF:
			    case TokenType.NOT:
			    case TokenType.BITWISE_NOT:
			    case TokenType.UNARY_PLUS:
			    case TokenType.UNARY_MINUS:
			    case TokenType.NEW:					
				// add operator
				tokenizer.get();
				operators.push(token.type);
				
				// match operand
				return scanOperand(operators, operands, stopAt, true);
				
			    // function casting
			    case TokenType.TYPE:
				var isArray:Boolean = tokenizer.peek(2).match(TokenType.ARRAY_DIMENSION);
				if (tokenizer.peek(2 + isArray).match(TokenType.LEFT_PAREN))
				{
					// push casting operator
					operators.push(TokenType.CAST);
					// push operands
					operands.push(parseType());
					tokenizer.match(TokenType.LEFT_PAREN, true);
					operands.push(parseExpression(TokenType.RIGHT_PAREN));
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					break;
				}
				// fall-through
			    
			    // array initialization/references
			    case TokenType.IDENTIFIER:
//[TODO] move this into NEW operator?
				// check for new operator
				if (operators[operators.length - 1] == TokenType.NEW &&
				    tokenizer.peek(2).match(TokenType.LEFT_BRACKET)) {
					// get type
					var type:Type = parseType();
					// get array initialization
					for (var sizes:Array = [], dimensions:int = 0; dimensions < 3; dimensions++) {
						// match an array dimension
						if (!tokenizer.match(TokenType.LEFT_BRACKET))
							break;

						sizes.push(parseExpression(TokenType.RIGHT_BRACKET))
						tokenizer.match(TokenType.RIGHT_BRACKET, true);
					}

					// create array initializer
					operators.pop();
					operands.push(new ArrayInstantiation(type, sizes[0], sizes[1], sizes[2]));
					break;
				} else if (!token.match(TokenType.IDENTIFIER)) {
					// invalid use of type keyword
					throw new TokenizerSyntaxError('Invalid type declaration', tokenizer);
				}
				
				// push reference
				tokenizer.get();
				operands.push(new Reference(new Literal(token.value)));
				break;
				
			    case TokenType.THIS:
				// push reference
				tokenizer.get();
				operands.push(new ThisReference());
				break;

			    // operands
			    case TokenType.NULL:
			    case TokenType.TRUE:
			    case TokenType.FALSE:
			    case TokenType.NUMBER:
			    case TokenType.STRING:
			    case TokenType.CHAR:
				// push literal
				tokenizer.get();
				operands.push(new Literal(token.value));
				break;
				
			    // array literal
			    case TokenType.LEFT_CURLY:
				// push array literal
				tokenizer.get();
				operands.push(new ArrayLiteral(parseList(TokenType.RIGHT_CURLY)));
				tokenizer.match(TokenType.RIGHT_CURLY, true);
				break;
			
			    // cast/group
			    case TokenType.LEFT_PAREN:
				tokenizer.get();

				// check if this be a cast or a group
				var isArray:Boolean = tokenizer.peek(2).match(TokenType.ARRAY_DIMENSION);
				if ((tokenizer.peek().match(TokenType.TYPE) ||
				    (isArray && tokenizer.peek().match(TokenType.IDENTIFIER))) &&
				    tokenizer.peek(2 + isArray).match(TokenType.RIGHT_PAREN))
				{
					// push casting operator
					operators.push(TokenType.CAST);
					// push operands
					operands.push(parseType());
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					return scanOperand(operators, operands, stopAt, true);
				}
				else if (tokenizer.peek(2).match(TokenType.RIGHT_PAREN) && tokenizer.match(TokenType.IDENTIFIER))
				{
					// match ambiguous parenthetical
					var identifier:String = tokenizer.currentToken.value;
					tokenizer.match(TokenType.RIGHT_PAREN, true);
					
					// check if this be a cast
					var tmpOperators:Array = [], tmpOperands:Array = [];
					if (scanOperand(tmpOperators, tmpOperands))
					{
						// add operators
						operators.push(TokenType.CAST);
						for each (var i:* in tmpOperators)
							operators.push(i);
						// add operands
						operands.push(new Type(identifier));
						for each (var i:* in tmpOperands)
							operands.push(i);
						break;
					}

					// not a cast; add operand
					operands.push(new Reference(new Literal(identifier)));
					break;
				}
				
				// parse parenthetical
				operands.push(parseExpression(TokenType.RIGHT_PAREN));
				if (!tokenizer.match(TokenType.RIGHT_PAREN))
					throw new TokenizerSyntaxError('Missing ) in parenthetical', tokenizer);
				break;
				
			    default:
				// missing operand
				if (required)
					throw new TokenizerSyntaxError('Missing operand', tokenizer);
				else
					return false;
			}

			// matched operand
			return true;
		}

		private function scanOperator(operators:Array, operands:Array, stopAt:TokenType = null):Boolean {		
			// get next token
			tokenizer.scanOperand = false;
			var token:Token = tokenizer.peek();
			// stop if token matches stop parameter
			if (stopAt && token.match(stopAt))
				return false;

			// switch based on type
			switch (token.type) {				
			    // assignment
			    case TokenType.ASSIGN:
				// combine any higher-precedence expressions (using > and not >=, so postfix > prefix)
				while (operators.length &&
				    operators[operators.length - 1].precedence > token.type.precedence)
					reduceExpression(operators, operands);
					
				// push operator
				operators.push(tokenizer.get().type);
				// expand assignment operators
				if (token.assignOp) {
					operators.push(token.assignOp);
					operands.push(operands[operands.length-1]);
				}
				// push assignment value
				operands.push(parseExpression(stopAt));

				// reached end of expression
				return false;
				
			    // dot operator
			    case TokenType.DOT:			
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= token.type.precedence)
					reduceExpression(operators, operands);
				
				// push operator
				operators.push(tokenizer.get().type);
				// match and push required identifier as string
				tokenizer.match(TokenType.IDENTIFIER, true);
				operands.push(new Literal(tokenizer.currentToken.value));

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);

			    // brackets
			    case TokenType.LEFT_BRACKET:
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= TokenType.INDEX.precedence)
					reduceExpression(operators, operands);

				// begin array index operator
				operators.push(TokenType.INDEX);
				tokenizer.match(TokenType.LEFT_BRACKET, true);
				operands.push(parseExpression(TokenType.RIGHT_BRACKET));
				if (!tokenizer.match(TokenType.RIGHT_BRACKET))
					throw new TokenizerSyntaxError('Missing ] in index expression', tokenizer);

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);
			
			    // operators
			    case TokenType.OR:
			    case TokenType.AND:
			    case TokenType.BITWISE_OR:
			    case TokenType.BITWISE_XOR:
			    case TokenType.BITWISE_AND:
			    case TokenType.EQ:
			    case TokenType.NE:
			    case TokenType.STRICT_EQ:
			    case TokenType.STRICT_NE:
			    case TokenType.LT:
			    case TokenType.LE:
			    case TokenType.GE:
			    case TokenType.GT:
			    case TokenType.INSTANCEOF:
			    case TokenType.LSH:
			    case TokenType.RSH:
			    case TokenType.URSH:
			    case TokenType.PLUS:
			    case TokenType.MINUS:
			    case TokenType.MUL:
			    case TokenType.DIV:
			    case TokenType.MOD:				
				// combine any higher-precedence expressions
				while (operators.length &&
				    operators[operators.length - 1].precedence >= token.type.precedence)
					reduceExpression(operators, operands);

				// push operator and scan for operand
				operators.push(tokenizer.get().type);
				break;
			
			    // increment/decrement
			    case TokenType.INCREMENT:
			    case TokenType.DECREMENT:
//[TODO] actually this doesn't actually work! how do we do a postfix in the middle of an expression...
				// postfix; reduce higher-precedence operators (using > and not >=, so postfix > prefix)
				while (operators.length &&
				    operators[operators.length - 1].precedence > token.type.precedence)
					reduceExpression(operators, operands);
					
				// add operator and reduce immediately
//[TODO] is reducing immediately necessary? a matter of precedence...
				operators.push(tokenizer.get().type);
				reduceExpression(operators, operands);
				
				// find next operator
				return scanOperator(operators, operands, stopAt);
				
			    // hook/colon operator
			    case TokenType.HOOK:
				// reduce left-hand conditional
				tokenizer.get();
				while (operators.length)
					reduceExpression(operators, operands);
				var conditional:IExecutable = operands.pop();
				// parse then block
				var thenBlock:IExecutable = parseExpression(TokenType.COLON);
				// parse else block
				tokenizer.match(TokenType.COLON, true);
				var elseBlock:IExecutable = parseExpression();
				
				// add conditional
				operands.push(new Conditional(conditional, thenBlock, elseBlock));
				// already matched expression
				return false;
			
			    // call/instantiation
			    case TokenType.LEFT_PAREN:
				// reduce until we get the current function (or lower operator precedence than 'new')
				while (operators.length &&
				    operators[operators.length - 1].precedence > TokenType.NEW.precedence)
					reduceExpression(operators, operands);

				// parse arguments
				tokenizer.match(TokenType.LEFT_PAREN, true);
				operands.push(parseList(TokenType.RIGHT_PAREN));
				tokenizer.match(TokenType.RIGHT_PAREN, true);
				
				// designate call operator, or that 'new' has args
				if (!operators.length || operators[operators.length - 1] != TokenType.NEW)
					operators.push(TokenType.CALL);
				else if (operators[operators.length - 1] == TokenType.NEW)
					operators.splice(-1, 1, TokenType.NEW_WITH_ARGS);
//[TODO] completely reduce here?
				// reduce now because CALL/NEW has no precedence
				reduceExpression(operators, operands);

				// operand already found; find next operator
				return scanOperator(operators, operands, stopAt);

			    // no operator found
			    default:
				return false;
			}

			// operator matched
			return true;
		}

//[TODO] integrate some of this into other functions?
		private function reduceExpression(operatorList:Array, operandList:Array):void {
			// extract operator and operands
			var operator:TokenType = operatorList.pop();
			var operands:Array = operandList.splice(operandList.length - operator.arity);
			// convert expression to statements
			switch (operator) {
			    // object instantiation
			    case TokenType.NEW:
			    case TokenType.NEW_WITH_ARGS:
			    {
				// processing.debugTextField.text += "\r parsing an instantiation ";
				// operands[0] contains the class to be instantiated
				// operands[1] contains an array with all the parameters to pass to the
				//             constructor method
				operandList.push(new ObjectInstantiation(operands[0], operands[1]));
				}
				break;
			    
			    // function call
			    case TokenType.CALL:
				operandList.push(new Call(operands[0], operands[1]));
				break;
			
			    // casting
			    case TokenType.CAST:
			        operandList.push(new Cast(operands[0], operands[1]));
			        break;
				
			    // increment/decrement
			    case TokenType.INCREMENT:
				operandList.push(new Increment(operands[0]));
				break;
			    case TokenType.DECREMENT:
			        operandList.push(new Decrement(operands[0]));
				break;
				
			    // assignment
			    case TokenType.ASSIGN:
				operandList.push(new Assignment(operands[0], operands[1]));
				break;
				
			    // property operator
			    case TokenType.INDEX:
			    case TokenType.DOT:
				operandList.push(new Reference(operands[1], operands[0]));
			        break;

			    // unary operators
			    case TokenType.NOT:
			    case TokenType.BITWISE_NOT:
			    case TokenType.UNARY_PLUS:
			    case TokenType.UNARY_MINUS:
				operandList.push(new Operation(operator, operands[0]));
				break;
		
			    // operators
			    case TokenType.OR:
			    case TokenType.AND:
			    case TokenType.BITWISE_OR:
			    case TokenType.BITWISE_XOR:
			    case TokenType.BITWISE_AND:
			    case TokenType.EQ:
			    case TokenType.NE:
			    case TokenType.STRICT_EQ:
			    case TokenType.STRICT_NE:
			    case TokenType.LT:
			    case TokenType.LE:
			    case TokenType.GE:
			    case TokenType.GT:
			    case TokenType.INSTANCEOF:
			    case TokenType.LSH:
			    case TokenType.RSH:
			    case TokenType.URSH:
			    case TokenType.PLUS:
			    case TokenType.MINUS:
			    case TokenType.MUL:
			    case TokenType.DIV:
			    case TokenType.MOD:
				operandList.push(new Operation(operator, operands[0], operands[1]));
				break;
			
			    default:
				throw new Error('Unknown operator "' + operator + '"');
			}
		}
	}
}
