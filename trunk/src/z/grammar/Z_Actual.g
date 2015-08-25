grammar Z; 

program
	: statement*
	;

//// Shared between expressions and statements

struct_block
	: '{' statement* '}'
	;

// Can represent either a function call or a function declaration.
function_argument_list
	: '(' ')'
	| '(' function_argument (',' function_argument)* ')'
	;

function_argument
	: expression Identifier?
	;



//// Statements

statement
	: type_definition_statement
	| declaration_or_expression_statement
	| block_statement
	| if_statement
	| null_statement
	;

type_definition_statement
	: 'struct' Identifier struct_block
	;

function_body
	: '{' statement* '}'
	| ';'
	;
	
declaration_or_expression_statement
	: (Identifier '(') => function_call_expression_or_declaration
	| expression
		( Identifier (';' | ('=' statement)) // declaration
		| Identifier function_argument_list function_body // function declaration
		| ';' // statement
		)
	;

function_call_expression_or_declaration
	: Identifier function_argument_list ';'
	;
	
block_statement
	: '{' statement* '}'
	;

if_statement
// options { backtrack=true; }
	: 'if' '(' expression ')' statement (('else') => 'else' statement)?
	; 
	
null_statement
	: ';'
	;
	
//// Expressions
	
expression
	: assignment_expression
	;

// Missing rules:
// conditional_expression ? :
// logical or ||
// logical and &&
// inclusive or |
// exclusive or ^
// and &

assignment_expression
	: equality_expression (assignment_operator assignment_expression)?
	;

assignment_operator
	: '='
	| '*='
	| '/='
	| '%='
	| '+='
	| '-='
	| '<<='
	| '>>='
	| '&='
	| '^='
	| '|='
	;

equality_expression
	: relational_expression (('==' | '!=') relational_expression)*
	;
	
relational_expression
	: additive_expression (('<'|'>'|'<='|'>=') additive_expression)*
	;
	
// Missing rule: shift_expression
additive_expression
	: multiplicative_expression (('+' | '-') multiplicative_expression)*
	;
	
multiplicative_expression
	: unary_expression (('*' | '/' | '%') unary_expression)*
	;

unary_expression
	: postfix_expression
	| unary_operator unary_expression
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	| '--'
	| '++'
	;

postfix_expression
	: primary_expression
        ( '[' expression ']'
        | function_argument_list
        | '.' Identifier
        | '->' Identifier
        | '++'
        | '--'
        )*
	;
	
primary_expression
	: Identifier
	| struct_expression
	| primary_literal
	| '(' expression ')'
	;

struct_expression
	: 'struct' struct_block
	;

primary_literal
	: Decimal_Literal
	;
	
//// Lexical elements

Identifier
	: Letter (Letter | '0'..'9')*
	;
	
fragment
Letter
	: '$'
	| 'A'..'Z'
	| 'a'..'z'
	| '_'
	;
	
Decimal_Literal
	: '0'..'9'*
	;

WS	: (' ' | '\r' | '\t' | '\u000C' | '\n') { skip(); }
	;

LINE_COMMENT
	: '//' ~('\n'|'\r')* '\r'? '\n' { skip(); }
	;


