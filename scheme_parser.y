// tokens
%token NOT_TOKEN
%token TOKEN_ARRAY
%token TOKEN_BOOL
%token TOKEN_CHAR
%token TOKEN_CHAR_LITERAL
%token TOKEN_ELSE
%token TOKEN_FALSE
%token TOKEN_FOR
%token TOKEN_FUNCT
%token TOKEN_IF
%token TOKEN_IDENT
%token TOKEN_INT
%token TOKEN_INT_LITERAL
%token TOKEN_PRINT
%token TOKEN_RETURN
%token TOKEN_STRING
%token TOKEN_STRING_LITERAL
%token TOKEN_TRUE
%token TOKEN_VOID
%token TOKEN_WHILE
%token TOKEN_PAREN_OPEN
%token TOKEN_PAREN_CLOSE
%token TOKEN_BRACKET_OPEN
%token TOKEN_BRACKET_CLOSE
%token TOKEN_BRACE_OPEN
%token TOKEN_BRACE_CLOSE
%token TOKEN_COMMA
%token TOKEN_SEMICOLON
%token TOKEN_COLON
%token TOKEN_INCREMENT
%token TOKEN_DECREMENT
%token TOKEN_NEGATION
%token TOKEN_EXP
%token TOKEN_MULT
%token TOKEN_DIVIDE
%token TOKEN_MOD
%token TOKEN_ADD
%token TOKEN_SUBTRACT
%token TOKEN_LT
%token TOKEN_LE
%token TOKEN_GT
%token TOKEN_GE
%token TOKEN_EQUAL
%token TOKEN_NE
%token TOKEN_L_AND
%token TOKEN_L_OR
%token TOKEN_ASSIGN
%union{
	struct decl* decl;
	struct stmt* stmt;
	struct expr* expr;
	struct param_list* param_list;
	struct type* type;
	char* ident;
};
// start symbol
%start program
// types of rules
%type <decl> program decl_list decl
%type <stmt> stmt stmt_list stmt_matched stmt_unmatched stmt_block
%type <expr> expr expr_list expr_opt not_empty_expr_list expr_or expr_and expr_cmp expr_add expr_mult expr_exp expr_unary expr_incr expr_group expr_primary expr_block not_empty_expr_list_block
%type <param_list> param param_list not_empty_param_list
%type <type> type
%type <ident> ident
// precedence from left to right
%left TOKEN_ADD TOKEN_SUBTRACT
%left TOKEN_MULT TOKEN_DIVIDE TOKEN_MOD
%{
// this maybe should be parser.bison, not parser.y
#include "decl.h"
#include "expr.h"
#include "stmt.h"
#include "type.h"
#include "param_list.h"
#include "token.h"   // ????
//#include "symbol.h"
//#include "hash_table.h"		// ????
#include <stdio.h>
#include <string.h>

/*
YYSTYPE is the lexical value returned by each rule in a bison grammar.
By default, it is an integer. In this example, we are returning a pointer to an expression.
*/
/*struct stype {
	struct decl* decl;
	struct stmt* stmt;
	struct expr* expr;
	struct param_list* param_list;
	struct type* type;
	char* ident;
} stype;
*/
//#define YYSTYPE stype		// ??????

/*
Clunky: Manually declare the interface to the scanner generated by flex. 
*/

extern char *yytext;
extern int yylex();
extern int yyerror( char *str );

struct decl * program = 0;
/*
Clunky: Keep the final result of the parse in a global variable,
so that it can be retrieved by main().
*/

//struct expr * parser_result = 0;
// c preamble
%}
// yacc preamble and token defs
%%
program: decl_list
		 { program = $1; }
	;
decl_list: decl decl_list
		{ $$ = $1; $1 -> next = $2; }
	| /* nothing */
		{ $$ = 0; }
	;
// function and global variable declarations
decl:	ident TOKEN_COLON type TOKEN_ASSIGN expr TOKEN_SEMICOLON
		{ $$ = decl_create($1, $3, $5, NULL, NULL ); }
	| ident TOKEN_COLON type TOKEN_SEMICOLON
		{ $$ = decl_create($1, $3, NULL, NULL, NULL ); }
	| ident TOKEN_COLON type TOKEN_ASSIGN stmt_block
		{ $$ = decl_create($1, $3, NULL, $5, NULL ); }
	| ident TOKEN_COLON type TOKEN_ASSIGN TOKEN_BRACE_OPEN not_empty_expr_list_block TOKEN_BRACE_CLOSE TOKEN_SEMICOLON
		{ $$ = decl_create($1, $3, $6, NULL, NULL ); }
	;
// datatypes
type:	TOKEN_STRING
		{ $$ = type_create(TYPE_STRING, NULL, NULL, NULL); }
	| TOKEN_INT
		{ $$ = type_create(TYPE_INTEGER, NULL, NULL, NULL); }
	| TOKEN_CHAR
		{ $$ = type_create(TYPE_CHARACTER, NULL, NULL, NULL); }
	| TOKEN_BOOL
		{ $$ = type_create(TYPE_BOOLEAN, NULL, NULL, NULL); }
	| TOKEN_VOID
		{ $$ = type_create(TYPE_VOID, NULL, NULL, NULL); }
	| TOKEN_ARRAY TOKEN_BRACKET_OPEN expr_opt TOKEN_BRACKET_CLOSE type
		{ $$ = type_create(TYPE_ARRAY, NULL, $5, $3); }	//where does the value for expr_opt go?
	| TOKEN_FUNCT type TOKEN_PAREN_OPEN param_list TOKEN_PAREN_CLOSE // can a function return a function/have a function as input
		{ $$ = type_create(TYPE_FUNCTION, $4, $2, NULL); }
	;
param_list: /* nothing */
		{ $$ = 0; }
	| not_empty_param_list
		{ $$ = $1; }
	;
not_empty_param_list: param
		{ $$ = $1; }
	| param TOKEN_COMMA not_empty_param_list
		{ $$ = $1; $1->next  = $3; }
	;
// function parameter/input
param: 	ident TOKEN_COLON type
		{ $$ = param_list_create($1, $3, NULL); }
	;
// variable/function name
ident:	TOKEN_IDENT
		{ char * temp; temp = strdup(yytext); $$ = temp; }
	;
// program statement
stmt:	stmt_matched
		{ $$ = $1; }
	| stmt_unmatched
		{ $$ = $1; }
	; 
// { stmt_list }
stmt_block: TOKEN_BRACE_OPEN stmt_list TOKEN_BRACE_CLOSE
		{ $$ = stmt_create(STMT_BLOCK, NULL, NULL, NULL, NULL, $2, NULL); }
	;
// no plain if
stmt_matched: decl
		{ $$ = stmt_create(STMT_DECL, $1, NULL, NULL, NULL, NULL, NULL); }
	| expr TOKEN_SEMICOLON	//????
		{ $$ = stmt_create(STMT_EXPR, NULL, NULL, $1, NULL, NULL, NULL ); }
	| TOKEN_FOR TOKEN_PAREN_OPEN expr_opt TOKEN_SEMICOLON expr_opt TOKEN_SEMICOLON expr_opt TOKEN_PAREN_CLOSE stmt_matched
		{ $$ = stmt_create(STMT_FOR, NULL, $3, $5, $7, $9, NULL); }
	| stmt_block
		{ $$ = $1; }
	| TOKEN_RETURN expr_opt TOKEN_SEMICOLON
		{ $$ = stmt_create(STMT_RETURN, NULL, NULL, $2, NULL, NULL, NULL); }
	| TOKEN_PRINT expr_list TOKEN_SEMICOLON
		{ $$ = stmt_create(STMT_PRINT, NULL, NULL, $2, NULL, NULL, NULL); }
	| TOKEN_IF TOKEN_PAREN_OPEN expr TOKEN_PAREN_CLOSE stmt_matched TOKEN_ELSE stmt_matched
		{ $$ = stmt_create( STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, $7 ); }
	;
// plain if
stmt_unmatched: TOKEN_IF TOKEN_PAREN_OPEN expr TOKEN_PAREN_CLOSE stmt
		{ $$ = stmt_create(STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, NULL);}
	| TOKEN_IF TOKEN_PAREN_OPEN expr TOKEN_PAREN_CLOSE stmt_matched TOKEN_ELSE stmt_unmatched
		{ $$ = stmt_create(STMT_IF_ELSE, NULL, NULL, $3, NULL, $5, $7);}
	| TOKEN_FOR TOKEN_PAREN_OPEN expr_opt TOKEN_SEMICOLON expr_opt TOKEN_SEMICOLON expr_opt TOKEN_PAREN_CLOSE stmt_unmatched
		{ $$ = stmt_create(STMT_FOR, NULL, $3, $5, $7, $9, NULL); }
	;
stmt_list: stmt stmt_list
		{ $$ = $1; $1 -> next = $2; }
	| /* nothing */
		{ $$ = 0; }
	;
not_empty_expr_list: expr TOKEN_COMMA not_empty_expr_list
		{ $$ = expr_create(EXPR_LIST, $1, $3); }
	| expr
		{ $$ = expr_create(EXPR_LIST, $1, NULL); }
	;
not_empty_expr_list_block:	expr_block TOKEN_COMMA not_empty_expr_list_block
		{ $$ = expr_create(EXPR_LIST, $1, $3); }
	| expr_block
		{ $$ = expr_create(EXPR_LIST, $1, NULL); }
	| not_empty_expr_list
		{ $$ = $1; }
	;
expr_block: TOKEN_BRACE_OPEN not_empty_expr_list_block TOKEN_BRACE_CLOSE
		{ $$ = expr_create(EXPR_BLOCK, NULL, $2); }
	;
expr_list: not_empty_expr_list	// function calls
		{ $$ = $1; }
	| /*nothing */
		{ $$ = 0; }
	;
expr_opt: /* nothing */
		{ $$ = 0; }
	| expr
		{ $$ = $1; }
	;
expr:	expr TOKEN_ASSIGN expr_or
		{ $$ = expr_create( EXPR_ASSIGN, $1, $3 ); }
	| expr_or
		{ $$ = $1; }
	;
// ||
expr_or: expr_or TOKEN_L_OR expr_and
		{ $$ = expr_create( EXPR_OR, $1, $3); }
	| expr_and
		{ $$ = $1; }
	;
// &&
expr_and: expr_and TOKEN_L_AND expr_cmp
		{ $$ = expr_create( EXPR_AND, $1, $3); }
	| expr_cmp
		{ $$ = $1; }
	;
// >, <, >=, <=, ==, !=
expr_cmp: expr_cmp TOKEN_GT expr_add
		{ $$ = expr_create( EXPR_GT, $1, $3); }
	| expr_cmp TOKEN_GE expr_add
		{ $$ = expr_create( EXPR_GE, $1, $3); }
	| expr_cmp TOKEN_LT expr_add
		{ $$ = expr_create( EXPR_LT, $1, $3); }
	| expr_cmp TOKEN_LE expr_add
		{ $$ = expr_create( EXPR_LE, $1, $3); }
	| expr_cmp TOKEN_EQUAL expr_add
		{ $$ = expr_create( EXPR_EQ, $1, $3); }
	| expr_cmp TOKEN_NE expr_add
		{ $$ = expr_create( EXPR_NE, $1, $3); }
	| expr_add
		{ $$ = $1; }
	;
// +, -
expr_add: expr_add TOKEN_ADD expr_mult
		{ $$ = expr_create( EXPR_ADD, $1, $3); }
	| expr_add TOKEN_SUBTRACT expr_mult
		{ $$ = expr_create( EXPR_SUB, $1, $3); }
	| expr_mult
		{ $$ = $1; }
	;
// *, /, %
expr_mult: expr_mult TOKEN_MULT expr_exp
		{ $$ = expr_create( EXPR_MUL, $1, $3); }
	| expr_mult TOKEN_DIVIDE expr_exp
		{ $$ = expr_create( EXPR_DIV, $1, $3); }
	| expr_mult TOKEN_MOD expr_exp
		{ $$ = expr_create( EXPR_MOD, $1, $3); }
	| expr_exp
		{ $$ = $1; }
	;
// ^
expr_exp: expr_exp TOKEN_EXP expr_unary
		{ $$ = expr_create( EXPR_EXP, $1, $3); }
	| expr_unary
		{ $$ = $1; }
	;
// !c, -c
expr_unary: TOKEN_SUBTRACT expr_unary
		{ $$ = expr_create( EXPR_NEG, NULL, $2); }
	| TOKEN_NEGATION expr_unary
		{ $$ = expr_create( EXPR_NOT, NULL, $2); }
	| expr_incr
		{ $$ = $1; }
	;
// c++, c--
expr_incr: expr_group TOKEN_INCREMENT
		{ $$ = expr_create( EXPR_INCR, $1, NULL); }
	| expr_group TOKEN_DECREMENT
		{ $$ = expr_create( EXPR_DECR, $1, NULL); }
	| expr_group
		{ $$ = $1; }
	;
// (), [], f()
expr_group: TOKEN_PAREN_OPEN expr TOKEN_PAREN_CLOSE		// grouping
		{ $$ = expr_create( EXPR_GROUP, $2, NULL); }
	| expr_primary TOKEN_BRACKET_OPEN expr TOKEN_BRACKET_CLOSE	// array subscript
		{ $$ = expr_create( EXPR_ARR, $1, $3); }
	| expr_primary TOKEN_PAREN_OPEN expr_list TOKEN_PAREN_CLOSE	// function call
		{ $$ = expr_create( EXPR_FUNCT, $1, $3); }
//	| TOKEN_BRACE_OPEN not_empty_expr_list TOKEN_BRACE_CLOSE
	| expr_primary
		{ $$ = $1; }
	;
// single unit in expression
expr_primary: ident 
		{ $$ = expr_create_name($1); }
	| TOKEN_INT_LITERAL 
		{ $$ = expr_create_integer_literal(atoi(yytext)); }
	| TOKEN_STRING_LITERAL 
		{ char * temp; temp = strdup(yytext); $$ = expr_create_string_literal(temp); }
	| TOKEN_CHAR_LITERAL
		{ $$ = expr_create_character_literal(*yytext); }
	| TOKEN_TRUE 
		{ $$ = expr_create_boolean_literal(1); }
	| TOKEN_FALSE 
		{ $$ = expr_create_boolean_literal(0); }
	;
%%
// c postamble
/*
This function will be called by bison if the parse should
encounter an error.  In principle, "str" will contain something
useful.  In practice, it often does not.
*/
int yyerror( char *str )
{
	printf("parse error: %s\n",str);
}
