    /* pilha.c
 * Implementação das operações realizadas sobre o TAD pilha */

#include "pilha.h"
#include <stdio.h>
#include <stdlib.h>

void stack_init(pilha * p)
{
	p->topo = -1;
}

bool stack_isempty(pilha p)
{
	return (p.topo == -1);
}

bool stack_isfull(pilha p)
{
	return (p.topo == STACK_MAX - 1);
}

void push(pilha * p, stack_info x)
{
	if (!stack_isfull(*p)) {
		p->itens[++p->topo] = x;
	}
	else {
		fprintf(stderr, "Overflow Stack!\n");
		exit(1);
	}
}

stack_info pop(pilha * p)
{
	if (!stack_isempty(*p)) {
		return p->itens[p->topo--];
	}
	else {
		printf("Analise Sintática Incorreta\n\n");
		exit(1);
	}
}

