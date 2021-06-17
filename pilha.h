/* pilha.h
 * Definição do TAD pilha e protótipo de suas operações*/

#ifndef _PILHA_H
#define _PILHA_H

#include <stdbool.h>

#define STACK_MAX 200
typedef int stack_info;
typedef struct {
	stack_info itens[STACK_MAX];
	int topo;
} pilha;

void stack_init(pilha *);

bool stack_isempty(pilha);

bool stack_isfull(pilha);

void push(pilha *, stack_info);

stack_info pop(pilha *, char * table_parser);

stack_info top(pilha p);

#endif
