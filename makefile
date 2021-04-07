lexico: main.o
	gcc -o lexico main.o -lfl

main.o: main.c
	gcc -c main.c

	
