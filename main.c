/*
Main program of calculator example.
Simply invoke the parser generated by bison, and then display the output.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "token.h"
//#include "expr.h"
//#include "stmt.h"
//#include "type.h"
//#include "decl.h"
//#include "parser.tab.h"

extern int yyparse();
extern int yylex();
extern struct decl * program;
int parse(char * file);
void scan(char * file);
void edit_string (char * s);

int main( int argc, char *argv[] ) {
	int result;
	if (!strcmp(argv[1], "-scan")) {
		scan(argv[2]);
	}
	else if (!strcmp(argv[1], "-parse")) {
		result = parse(argv[2]);	
	}
	else {
		printf("incorrect flag\n");
	}
	return result;
}

int parse(char * file) {
	extern FILE * yyin;
	extern char * yytext;
	yyin = fopen(file, "r");
	if (!yyin) {
		printf("invalid file.\n");
		return 2;
	}
	if(yyparse()==0) {
		printf("parse successful");
		decl_print(program, 0);
		printf("\n");
		return 0;
	} else {
		printf("parse failed!\n");
		return 1;
	}
}

void scan(char * file) {
	extern FILE * yyin;
	extern char * yytext;
	yyin = fopen(file,"r");
	while (1) {
		int t = yylex();
		if (yytext[0]=='\0') {
			exit(0);
			break;
		}
		if (t==NOT_TOKEN) {
			fprintf(stderr, "scan error: %s is not a valid character\n", yytext);
			exit(1);
			break;
		}
		else if (!t) {
			exit(0);
			break; 
		}
		else {
			if (t==TOKEN_STRING_LITERAL /*|| t==TOKEN_INT_LITERAL */|| t==TOKEN_CHAR_LITERAL) {
				if (t!=TOKEN_INT_LITERAL) 
					edit_string(yytext);
				if (strlen(yytext)>255 && t==TOKEN_STRING_LITERAL) {
					fprintf(stderr, "scan error: string too long\n");
					exit(1);
				}
				else {
					printf("%s %s\n", token_string(t), yytext);
				}
			}
			else {
				if (strlen(yytext)<256 || t!=TOKEN_IDENT) {
					printf("%s\n", token_string(t));
				}
				else {
					fprintf(stderr, "scan error: identifier too long\n");
					exit(1);
				}
			}
		}
	}
	return;
}

void edit_string (char * s) {
	int i, j;
	for (j=1; j<strlen(s); j++) {	// remove "/'
		s[j-1] = s[j];
	}
	s[j-2]='\0';	// end quote removed
	for (i=0; i<strlen(s); i++) {	// scan string
		if (s[i]=='\\') {
			if (s[i+1]=='0') {
				s[i] = '\0';
			}
			else if (s[i+1]=='n') {
				s[i] = '\n';
			}
			else {
				s[i] = s[i+1];
			}
			for (j=i+1; j<strlen(s); j++) {	// remove '\'
				s[j] = s[j+1];
			}
			s[j] = '\0';
		}
	}
}
