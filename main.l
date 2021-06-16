/*
********************************************************************************************
TÍTULO:	Analisador léxico, utilizando o flex por meio de expressões regulares.
********************************************************************************************

********************************************************************************************
DESCRIÇÃO:
		Este código tem como intuito demonstrar o uso de um analisador léxico, abordada
		a teoria na disciplina de compiladores, no qual ira tentar formar tokens 
		reconhecidos pela linguagem, independente do seu significado semântico. Para maior 
		riqueza em detalhes, por favor consultar o arquivo "documentacao.docx".
********************************************************************************************

********************************************************************************************
AUTORES: Felipe Ferreira, Gabriel Romano, Jaime Mathias
********************************************************************************************
*/

%{

#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include "pilha.h"

/* 
* ** Utilizar essa área para criação de variaveis públicas  **
*/

#define TERMINAL_DIGIT 0
#define TERMINAL_OP_BINARIO 1
#define TERMINAL_OP_UNARIO 2
#define ERROR_LEXICO false

char buffer_entrada[500]; // buffer utilizado para capturar entrada da expressão no terminal
unsigned int buffer_saida[500], ptr_entrada = 0;
bool STATE_ERROR = true;



/* 
* ** Utilizar essa área para criação de variaveis privadas **
*/

static int id_token;	 //variavel para controle dos tokens formados.


/*
* ** Prototipos de funcoes publicas **;
*/
void print_token(char * buffer_entrada, char * msg, char * type_terminal); //prototipo de função para imprimir na tela um token reconhecido
int aval_postfixa(const int * buffer_saida);
%}


/*
********************************************************************************************
* 				************ SEÇÃO DE DEFINIÇÕES ************
* Definições das expressões regulares que serão utilizadas pelo flex para validação léxica
* das palavras de entrada capturadas pelo buffer. 
* Utilize a área abaixo para definição das palavras reconhecidas pela linguagem.
* *******************************************************************************************   
*/

COMANDO \<enter>

DIGITO [0-9]


OP_UNARIO  \<(\cos|\sen|\log)\>

OP_BINARIO \<(\+|\-|\*|\/|\^)\>

INTEIRO (\<({DIGITO}+)\>)+

FLOAT ({INTEIRO}\<[.]\>{INTEIRO})

%%

{INTEIRO} 		{ 
					print_token(buffer_entrada, "número inteiro!", "terminal_digit");
	      		}

{FLOAT} 		{
					print_token(buffer_entrada, "número tipo float", "terminal_digit") ;
				}


{OP_UNARIO} 	{ 
					print_token(buffer_entrada, "operador unário!", "terminal_op_unario"); 
				}

{OP_BINARIO} 	{ 	
					print_token(buffer_entrada, "operador binario!", "terminal_op_binario"); 
				}

{COMANDO} 		{ 
			  		print_token(buffer_entrada, "comando detectado!", "terminal_lambda"); 
				}

[[:space:]]+ ;

[[:^space:]]+ 	{ 
					print_token(buffer_entrada, "erro" , "invalid"); 
				};
%%


/*
********************************************************************************************
* 				************ SEÇÃO DE IMPLEMENTAÇÃO DAS FUNÇOES PRIVADAS ************
* Implementações das funções privadas.
* Utilize a área abaixo para a implementação das funções privadas.
* ******************************************************************************************
*/

/*
 * @Param: string; Return: void;
 * Bloco responsavel por enviar o buffer capturado no terminal para 
 * ser feito a analise lexica utilizando as expressões regulares definidas pelo flex.
*/ 
static void regexp(char * input)
{
	/*Obtem o novo buffer*/
	yy_scan_string(input);

	/*Analiza a string*/
	yylex();

	/*Desaloca o buffer*/
    yy_delete_buffer(YY_CURRENT_BUFFER);
}

/*
 * @Param: caracter; Return: bool;
 * Bloco responsavel por validar os caracteres pertencente ao alfabeto da linguagen.
 * O programa recebe uma ou varias expressoes em um unico buffer de entrada.
*/ 
static bool is_valido(char c)
{
	return ((c >= 48 && c <= 57) || c == '.');
}

/*
 * @Param: caracter; Return: bool;
 * Bloco responsavel por validar as "n" expressões capturadas na entrada
 * delimitadas pelo simbolo "delimitador" pertencente ao alfabeto
*/ 
static bool is_delimitador(char c)
{
	return (c == '<' || c == '>');
}

/*
 * @Param: string; Return: void;
 * Bloco responsavel pela simulação do controle da fita de entrada
 * alterando em uma maquina de 3 estados, afim de reconhecer as delimitações das
 * "n" expressões capturadas no buffer. Também por enviar para o flex, processar as expressões
 *  regulares definidas na seção definição.
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
			if (aguardo) regexp(buffer_entrada); //enviar o buffer, para analise das expressões regulares definidas no flex
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
				regexp(buffer_entrada); //enviar o buffer, para analise das expressões regulares defini
				j = 0;
				aguardo = false;
			}
		}
	}
	if (aguardo) {
		regexp(buffer_entrada); //enviar o buffer, para analise das expressões regulares defini
	}
}

/*
********************************************************************************************
* 				************ SEÇÃO DE IMPLEMENTAÇÃO DAS FUNÇOES PÚBLICAS ************
* Implementações das funções públicas.
* Utilize a área abaixo para a implementação das funções públicas.
* ******************************************************************************************
*/


void print_buffer(unsigned int * bf)
{

	for (int i = 0; bf[i] != '$'; i++)
		printf("%d. %d\n", i, bf[i]); 
}

bool is_simbolo_terminal(char * simbolo)
{
	if (strcmp(simbolo, "terminal_digit") == 0)  buffer_saida[ptr_entrada++] =  TERMINAL_DIGIT;
	else if (strcmp(simbolo, "terminal_op_binario") == 0) buffer_saida[ptr_entrada++]= TERMINAL_OP_BINARIO;
	else if (strcmp(simbolo, "terminal_op_unario") == 0) buffer_saida[ptr_entrada++] = TERMINAL_OP_UNARIO;
	else if (strcmp(simbolo, "invalid") == 0) STATE_ERROR = ERROR_LEXICO;

	//printf("Simbolo : %s ;  Buffer[%d] = %d\n", simbolo, ptr_entrada, buffer_saida[ptr_entrada]);

	buffer_saida[ptr_entrada] = '$';

}


/*
 * @Param: string, caracter; Return: bool;
 * Bloco responsavel por imprimir na tela os tokens formados
 * pelas regras das expressoes regulares definidas no flex.
*/ 
void print_token(char * buffer_entrada, char * msg, char * simbolo)
{
	int i;
	
	printf("Token reconhecido: [ ");
	for (i = 0; buffer_entrada[i] != '\0'; i++) {
		if (!is_delimitador(buffer_entrada[i]))
			printf("%c", buffer_entrada[i]);
			
			//buffer_saida[ptr_entrada++] = '$';
	}
	printf(" ]\tTipo do Token: [ %s ]\tidatrr: [ %d ]\n\n", msg, ++id_token);
	
	if (is_simbolo_terminal(simbolo));
}

int main(int argc, char** argv) 
{
	
    char input[40];

    while (1) {
		id_token = 0;
		ptr_entrada = 0;
		STATE_ERROR = true;

		printf("Entre com a expressão[digite: \"sair\" para encerrar]: ");
		scanf("%s", input); //read sem tratamento
		printf("\n");

		if (!strcmp(input, "sair")) break;
		
		processar_buffer(input); 
		//print_buffer(buffer_saida);

		if (STATE_ERROR) {
			printf("Lexico Correto\n\n");
			aval_postfixa(buffer_saida);
		} else {
			printf("Lexico Incorreto\n\n");
		}

	}
		return 0;
}


int aval_postfixa(const int * buffer_saida)
{
    pilha p;
    int i = 0, x, y;
    stack_init(&p);

    while (buffer_saida[i] != '$') {
        if (buffer_saida[i] == 0) {
            push(&p, 1);
            i++;
        }
        else {
            switch(buffer_saida[i]) {
                case 1:
                    y = pop(&p);
                    x = pop(&p); // Caso não tenha 2 numeros, trazer erro?
                    push(&p, x + y); // PODERIA ARMAZENAR ATÉ O NUMERO 1
                    break;
                case 2:
                    y = pop(&p); // Operador unário
                    push(&p, y + 1); // PODERIA ARMAZENAR ATÉ O NUMERO 1
                    break;
            }
            i++;
        }
    }
    x =  pop(&p);
    
    if (stack_isempty(p)) {
        printf("Analise Sintática Correta\n\n");
        return 0;
    }
    else {
        printf("Analise Sintática Incorreta\n\n");
        return 2;
    }
}
