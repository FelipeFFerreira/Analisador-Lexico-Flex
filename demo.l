%{

#include <stdio.h>

%}

COMANDO \<enter>

DIGITO [0-9]

INTEIRO (\<({DIGITO}+)\>)+

FLOAT ({INTEIRO}\<[.]\>{INTEIRO})

%%

{INTEIRO}{COMANDO} { printf(">Encontrei um inteiro na string %s e seu sucessor é %d!\n", yytext, atoi(yytext) + 1); }
{FLOAT}{COMANDO} { printf("float!\n"); }

[[:space:]]+ ;
[[:^space:]]+ ;

%%

int main() 
{
	yylex(); 
	return 0;
}