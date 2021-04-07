%{

#include <stdio.h>
#include <string.h>
#include <stdbool.h>

char str[500];
static int id_token;

void print_str(char * str, char * msg);

%}

COMANDO \<enter>

DIGITO [0-9]


OP_UNARIO  \<(\cos|\sen|\log|\^)\>

OP_BINARIO \<(\+|\-|\*|\/)\>

INTEIRO (\<({DIGITO}+)\>)+

FLOAT ({INTEIRO}\<[.]\>{INTEIRO})

%%

{INTEIRO} 		{ 
					print_str(str, "número inteiro!");
	      		}

{FLOAT} 		{
					print_str(str, "número tipo float") ;
				}


{OP_UNARIO} 	{ 
					print_str(str, "operador unário!"); 
				}

{OP_BINARIO} 	{ 	
					print_str(str, "operador binario!"); 
				}

{COMANDO} 		{ 
			  		print_str(str, "comando detectado!"); 
				}

[[:space:]]+ ;

[[:^space:]]+ 	{ 
					print_str(str, "erro"); 
				};
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

void print_str(char * str, char * msg)
{
	int i;
	printf("Token reconhecido: [ ");
	for (i = 0; str[i] != '\0'; i++) {
		if (!is_delimitador(str[i]))
			printf("%c", str[i]);
	}
	printf(" ]\tTipo do Token: [ %s ]\tidatrr: [ %d ]\n\n", msg, ++id_token);
}

void processar_string(char * input)
{
	int i, j;
	bool inicio_comando = false, fim_comando = false, aguardo = false;

	for (i = 0, j = 0; input[i] != '\0'; i++) {
		
		if ( !inicio_comando && ( (is_delimitador(input[i]) && is_digito(input[i + 1]) ) || is_digito(input[i]) || ( is_delimitador(input[i]) && is_delimitador(input[i + 1]) ) ) || input[i + 1] == '\0' ) {

			str[j] = input[i];
			str[j + 1] = '\0';
			j += 1;
			aguardo = true;
			
		} else if (!fim_comando) {
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
				j = 0;
				aguardo = false;
			}
		}
	}
	if (aguardo) {
		regexp(str);
	}
}


int main(int argc, char** argv) 
{
	
    char input[40];

    while (1) {
    	id_token = 0;
    	printf("Entre com a expressão[digite: \"sair\" para encerrar]: ");
    	scanf("%s", input); //read sem tratamento
    	printf("\n");

    	if (!strcmp(input, "sair")) break;
    	else processar_string(input); 	
    }

	return 0;
}