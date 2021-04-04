%{

#include <stdio.h>
#include <string.h>
#include <stdbool.h>



%}

COMANDO \<enter>

DIGITO [0-9]


OP_UNARIO  \<(\cos|\sen|\log|\^)\>

OP_BINARIO \<(\+|\-|\*|\/)\>

INTEIRO (\<({DIGITO}+)\>)+

FLOAT ({INTEIRO}\<[.]\>{INTEIRO})

%%

{INTEIRO} 	{ 
				printf(">número inteiro!\n");
				yylex(); 
	      	}

{FLOAT} 	{
				printf(">número ponto fluatuante\n"); 
			}


{OP_UNARIO} { printf("operador unário!\n"); }

{OP_BINARIO} { printf("operador binario!\n"); }

{COMANDO} { printf(">comando\n"); }



[[:space:]]+ ;
[[:^space:]]+ { printf("erro\n"); };

%%

void regexp(char * input)
{
	/*Copy string into new buffer and Switch buffers*/
	yy_scan_string(input);

	/*Analyze the string*/
	yylex();

	/*Delete the new buffer*/
    yy_delete_buffer(YY_CURRENT_BUFFER);

}

bool is_digito(char c)
{
	return (c >= 48 && c <= 57);
}

bool is_delimitador(char c)
{
	return (c == '<' || c == '>');
}

void processar_string(char * input)
{
	int i, j;
	char str[100];
	bool especial = false;

	for (i = 0, j = 0; input[i] != '\0'; i++) {

		if (is_delimitador(input[i]) || is_digito(input[i])) {
			if (input[i] == '<' && !is_digito(input[i + 1])) {
				regexp(str);
				j = 0;
				especial = true;
			}
			str[j] = input[i];
			str[j + 1] = '\0';

			if (especial && input[i] == '>') regexp(str);

			printf("%c, %d", input[i], i);
			//especial = true;
		} 
		else {
			//regexp(input);
			str[j] = input[i];
			printf("%c, %d :)", input[i], i);
		}
		j += 1;
		printf("\n");	
	}
}


int main(int argc, char** argv) 
{
	
    char input[40];

    while (1) {
    	scanf("%s", input); //read sem tratamento

    	if (!strcmp(input, "sair")) break;
    	else processar_string(input);
    	break;

    }

	return 0;
}