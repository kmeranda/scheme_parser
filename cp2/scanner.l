/*Kelsey Meranda, Rosalyn Tan, Kim Forbes*/

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
.			{ printf("scan error: bad token: %c\n",yytext[0]); }
%%
