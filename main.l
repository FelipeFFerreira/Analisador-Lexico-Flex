/*
********************************************************************************************
TÍTULO:	Analisador léxico, utilizando o flex por meio de expressões regulares.
********************************************************************************************

********************************************************************************************
DESCRIÇÃO:
		Este código tem como intuito demonbuffer_entradaar o uso de um analisador léxico, abordada
		a teoria na disciplina de compiladores, no qual ira tentar formar tokens 
		reconhecidos pela linguagem, independente do seu significado semântico. Para maior 
		riqueza em detalhes, por favor consultar o arquivo "documentacao.txt".
********************************************************************************************

********************************************************************************************
AUTORES: Felipe Ferreira, Gabriel Romano, Jaime Mathias
********************************************************************************************
*/

%{

#include <stdio.h>
#include <string.h>
#include <stdbool.h>

/* 
* ** Utilizar essa área para criação de variaveis públicas  **
*/
char buffer_entrada[500]; // buffer utilizado para captura entrada da expressão no terminal.

/* 
* ** Utilizar essa área para criação de variaveis privadas **
*/
static int id_token;	 //variavel para controle dos tokens formados.


/*
* ** Prototipos de funcoes publicas **;
*/
void print_token(char * buffer_entrada, char * msg); //prototipo função para imprimir na tela um token

%}


COMANDO \<enter>

DIGITO [0-9]


OP_UNARIO  \<(\cos|\sen|\log|\^)\>

OP_BINARIO \<(\+|\-|\*|\/)\>

INTEIRO (\<({DIGITO}+)\>)+

FLOAT ({INTEIRO}\<[.]\>{INTEIRO})

%%

{INTEIRO} 		{ 
					print_token(buffer_entrada, "número inteiro!");
	      		}

{FLOAT} 		{
					print_token(buffer_entrada, "número tipo float") ;
				}


{OP_UNARIO} 	{ 
					print_token(buffer_entrada, "operador unário!"); 
				}

{OP_BINARIO} 	{ 	
					print_token(buffer_entrada, "operador binario!"); 
				}

{COMANDO} 		{ 
			  		print_token(buffer_entrada, "comando detectado!"); 
				}

[[:space:]]+ ;

[[:^space:]]+ 	{ 
					print_token(buffer_entrada, "erro"); 
				};
%%


/* 
* ** Utilizar essa área para a implementação das funções privadas **
*/

/*
 * Param: buffer_entradaing; Return: void;
 * Bloco responsavel por enviar o buffer capturado no terminal para 
 * ser feito a analise lexica utilizando expressões regulares 
 * definidas pelo flex.
*/ 
static void regexp(char * input)
{
	yy_scan_string(input);

	/*Analiza a string*/
	yylex();

    yy_delete_buffer(YY_CURRENT_BUFFER);
}

/*
 * Param: caracter; Return: bool;
 * Bloco responsavel por validar os caracteres pertencente ao alfabeto
 * digitas na entrada.
 * O programa recebe uma ou varias expressoes em um unico buffer de entrada.
*/ 
static bool is_valido(char c)
{
	return ((c >= 48 && c <= 57) || c == '.');
}

/*
 * Param: caracter; Return: bool;
 * Bloco responsavel por validar as "n" expressões capturadas na entrada
 * delimitadas pelo simbolo "delimitador" pertencente ao alfabeto
*/ 
static bool is_delimitador(char c)
{
	return (c == '<' || c == '>');
}

/*
 * Param: string; Return: void;
 * Bloco responsavel pela simulação do controle da fita de entrada
 * alterando em uma maquina de 3 estados afim de reconhecer as delimitações das
 * "n" expressões capturadas no buffer.
*/ 
static void processar_buffer(char * input)
{
	int i, j;
	bool inicio_comando = false, fim_comando = false, aguardo = false;

	for (i = 0, j = 0; input[i] != '\0'; i++) {
		
		if ( !inicio_comando && ( (is_delimitador(input[i]) && is_valido(input[i + 1]) ) ||
			 is_valido(input[i]) || ( is_delimitador(input[i]) && is_delimitador(input[i + 1]))) ||
			 input[i + 1] == '\0' ) {

			buffer_entrada[j] = input[i];
			buffer_entrada[j + 1] = '\0';
			j += 1;
			aguardo = true;
			
		} else if (!fim_comando) {
			if (aguardo) regexp(buffer_entrada);
			j = 0;
			buffer_entrada[j] = input[i];
			buffer_entrada[j + 1] = '\0';
			j += 1;
			inicio_comando = true;
			fim_comando = true;
		} else if (fim_comando) {
			buffer_entrada[j] = input[i];
			buffer_entrada[j + 1] = '\0';
			j += 1;

			if (is_delimitador(input[i])) {
				inicio_comando = false;
				fim_comando = false;
				regexp(buffer_entrada);
				j = 0;
				aguardo = false;
			}
		}
	}
	if (aguardo) {
		regexp(buffer_entrada);
	}
}

/* 
* ** Utilizar essa área para a implementação das funções públicas **
*/

/*
 * Param: caracter; Return: bool;
 * Bloco responsavel imprimir na tela os tokens formados
 * pelas regras das expressoes regulares definidas no flex.
*/ 
void print_token(char * buffer_entrada, char * msg)
{
	int i;
	printf("Token reconhecido: [ ");
	for (i = 0; buffer_entrada[i] != '\0'; i++) {
		if (!is_delimitador(buffer_entrada[i]))
			printf("%c", buffer_entrada[i]);
	}
	printf(" ]\tTipo do Token: [ %s ]\tidatrr: [ %d ]\n\n", msg, ++id_token);
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
    	else processar_buffer(input); 	
    }

	return 0;
}