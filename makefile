lexparser: main.o pilha.o
	gcc -o lexparser main.o pilha.o -lfl

main.o: main.c pilha.h
	gcc -c main.c

pilha.o: pilha.c pilha.h
	gcc -c pilha.c
	
