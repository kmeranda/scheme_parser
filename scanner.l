%option noyywrap
%option nounput
%option noinput
%{
#include "parser.tab.h"
%}

DIGIT 	[0-9]
LETTER	[a-zA-Z_]

%%

[ \n\r\t]*		;
{DIGIT}*		return TOKEN_INTEGER;
{DIGIT}*(\.{DIGIT}*)?	return TOKEN_FLOAT;
\*			return TOKEN_MULTIPLY;
\+			return TOKEN_ADD;
\-			return TOKEN_SUBTRACT;
\/			return TOKEN_DIVIDE;
\(			return TOKEN_LPAREN;
\)			return TOKEN_RPAREN;
\;			return TOKEN_SEMI;
car			return TOKEN_CAR;
lat\?			return TOKEN_LAT;
atom\?			return TOKEN_ATOM;
.			{ printf("scan error: bad token: %c\n",yytext[0]); }
%%

/* I removed the rule {LETTER}*	return TOKEN_ID; just as a heads up*/

/*
flex calls yywrap() whenever it reaches the end of the current file.
If yywrap returns false to indicate the end of the program.
It could alternatively open up another file and return true,
so that flex would keep going.
*/

/*
int yywrap() {
	return 0;
}
*/
