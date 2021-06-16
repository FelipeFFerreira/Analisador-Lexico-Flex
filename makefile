lexico: main.o pilha.o
	gcc -o lexico main.o pilha.o -lfl

main.o: main.c pilha.h
	gcc -c main.c

pilha.o: pilha.c pilha.h
	gcc -c pilha.c
	
