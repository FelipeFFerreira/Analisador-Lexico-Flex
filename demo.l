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
				printf("\n=>número inteiro!\n");
				yylex(); 
	      	}

{FLOAT} 	{
				printf("\n=>número ponto fluatuante\n"); 
			}


{OP_UNARIO} { printf("\n=>operador unário!\n"); }

{OP_BINARIO} { printf("\n=>operador binario!\n"); }

{COMANDO} { printf("\n=>comando\n"); }



[[:space:]]+ ;
[[:^space:]]+ { printf("\n=>erro\n"); };

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
	return ((c >= 48 && c <= 57) || c == '.');
}

bool is_delimitador(char c)
{
	return (c == '<' || c == '>');
}

void print_str(char * str)
{
	int i;
	for (i = 0; str[i] != '\0'; i++) {
		if (!is_delimitador(str[i]))
			printf("%c", str[i]);
	}
}

void processar_string(char * input)
{
	int i, j;
	char str[500];
	bool inicio_comando = false, fim_comando = false, aguardo = false;

	for (i = 0, j = 0; input[i] != '\0'; i++) {
		
		if ( !inicio_comando && ( (is_delimitador(input[i]) && is_digito(input[i + 1]) ) || is_digito(input[i]) || ( is_delimitador(input[i]) && is_delimitador(input[i + 1]) ) ) ) {

			str[j] = input[i];
			str[j + 1] = '\0';
			j += 1;
			aguardo = true;
			
		} else if (!fim_comando) {
			printf("%s, %d\n", str, i);
			if (aguardo) regexp(str);
			j = 0;
			str[j] = input[i];
			str[j + 1] = '\0';
			j += 1;
			inicio_comando = true;
			fim_comando = true;
		} else if (fim_comando) {
			str[j] = input[i];
			str[j + 1] = '\0';
			j += 1;

			if (is_delimitador(input[i])) {
				inicio_comando = false;
				fim_comando = false;
				regexp(str);
				printf("%s, %d\n", str, i);
				j = 0;
				aguardo = false;
			}
		}
	}
	if (aguardo) {
		regexp(str);
		printf("%s, %d\n", str, i);
	}
}


int main(int argc, char** argv) 
{
	
    char input[40];

    while (1) {
    	printf("Entre com a expressão: ");
    	scanf("%s", input); //read sem tratamento
    	printf("\n");

    	if (!strcmp(input, "sair")) break;
    	else processar_string(input); 	
    }

	return 0;
}