/*Kelsey Meranda, Rosalyn Tan, Kim Forbes*/

/* declare tokens from scanner */
%token TOKEN_INTEGER
%token TOKEN_FLOAT
%token TOKEN_SEMI
%token TOKEN_ADD
%token TOKEN_SUBTRACT
%token TOKEN_MULTIPLY
%token TOKEN_DIVIDE
%token TOKEN_LPAREN
%token TOKEN_RPAREN
%token TOKEN_CAR
%token TOKEN_LAT
%token TOKEN_ATOM

/* define different types */
%union {
	int int_pointer;
	int* int_array;
};
%type <int_pointer> program expr func term list list_item
/*%type <int_array> list list_item*/

%{

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

extern char *yytext;
extern int yylex();
extern int yyerror( char *str );

double parser_result = 0.0;

%}

%%

/* program is the start symbol. */
/* grammar for scheme*/
program	: expr
		{ parser_result = $1; return 0; }
	;
/* expression that returns a single value (ints) */
expr	: TOKEN_LPAREN func TOKEN_RPAREN
		{ $$ = $2; }
	| term
		{ $$ = $1; } 
	;
/* functions that returns a single value */
func	: TOKEN_ADD expr expr
		{ $$ = $2 + $3; }
	| TOKEN_SUBTRACT expr expr
		{ $$ = $2 - $3; }
	| TOKEN_MULTIPLY expr expr
		{ $$ = $2 * $3; }
	| TOKEN_DIVIDE expr expr
		{
			if($3==0) {
				printf("Error: cannot divide by zero\n");
				exit(1);
			}
			$$ = $2 / $3;
		}
	| TOKEN_CAR list
		{ $$ = $2; }
	;
/* single value (int) */
term	: TOKEN_INTEGER
		{ $$ = atoi(yytext); }
	;
/* list of values (type array of ints) */
list	: TOKEN_LPAREN list_item TOKEN_RPAREN
		{ $$ = $2; }
	;
list_item : expr list_item
		{ $$ = $1; }
	| expr	
		{ $$ = $1; }	
	;
%%

int yyerror( char *str ) {
	printf("parse error: %s\n",str);
	return 0;
}
