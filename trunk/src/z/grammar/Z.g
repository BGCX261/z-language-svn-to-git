grammar Z;

@header {
package z.grammar;
import java.util.HashMap;
import java.util.Vector;
import z.*;
}

@members {
void pr(String s) { System.out.println(s); }
}

@lexer::header {
package z.grammar;
}

program returns [Program value]
	: {
		$value = new Program(new Vector<Statement>());
	}
	(statement {
		$value.append($statement.value);
	}
	)*
	;

statement returns [Statement value]
	: null_statement { $value = $null_statement.value; }
	| declaration_or_expression_statement { 
		$value = $declaration_or_expression_statement.value;
	}
	;

null_statement returns [Statement value]
	: ';' { $value = new NullStatement(); }
	;

// handles:
// "expression ;" -> expression 
// "expression identifier ;" -> declaration
// "expression identifier = statement" -> declaration + initializer
// Note that this case can result in bizarre declarations such as
// "int x = int y = 1;", but it also facilitates "int x = if (z) 1;
// else 2;" and block initializers.

declaration_or_expression_statement returns [Statement value]
//	: (Identifier '(') => function_call_expression_or_declaration
	: expression (
			identifier_expression (
				';' {
					$value = new DeclarationStatement(
						$expression.value,
						$identifier_expression.value);
				} | ('=' statement {
					$value = new DeclarationStatement(
						$expression.value,
						$identifier_expression.value,
						$statement.value);
				}
				)
			)
		| ';' {
			$value = new ExpressionStatement($expression.value);
		}
	)
	;

expression returns [Expression value]
	: additive_expression {
		$value = $additive_expression.value;
	}
	;

additive_expression returns [Expression value]
	: e=primary_expression {
		$value = $e.value;
	}
	('+' e=primary_expression {
		$value = new BinaryOperatorExpression(
			new Add(),
			$value,
			$e.value);
	})*
	;

primary_expression returns [Expression value]
	: integer_expression {
		$value = $integer_expression.value;
	}
	| identifier_expression {
		$value = $identifier_expression.value;
	}
	;

integer_expression returns [IntegerExpression value]
	: INTEGER {
		$value = new IntegerExpression(
			Integer.parseInt($INTEGER.text));
	}
	;

identifier_expression returns [IdentifierExpression value]
	: IDENTIFIER {
		$value = new IdentifierExpression($IDENTIFIER.text);
	}
	;

//	: expression
//		( Identifier (';' | ('=' statement)) // declaration
//		| Identifier function_argument_list function_body // function declaration
//		| ';' // statement
//		)
//	;
/*
stat returns [Stat value]
	: expr NEWLINE { value = new ExprStat($expr.value); }
	| ID '=' expr NEWLINE {
		value = new AssignStat($ID.text, $expr.value);
	}
	| NEWLINE
	;
	
expr returns [Expr value]
	: e=multExpr {
		$value = $e.value;
	} (
		('+' e=multExpr) {
			$value = new AddExpr($value, $e.value);
		}
	|	('-' e=multExpr) {
			$value = new SubExpr($value, $e.value);
		}
	)*
	;

multExpr returns [Expr value]
	: e=atom {
		$value = $e.value;
	} ('*' e=atom {
		$value = new MultExpr($value, $e.value);
	}
	)*
	;

atom returns [Expr value]
	: INT { $value = new IntExpr(Integer.parseInt($INT.text)); }
	| ID { $value = new IdExpr($ID.text); }
	| '(' expr ')' { $value = $expr.value; }
	;

*/

IDENTIFIER
	: ('a'..'z'|'_'|'A'..'Z')+
	;

INTEGER
	: '0'..'9'+
	;

WS	: (' ' |'\t' |'\n' |'\r' )+ { skip(); } ;

