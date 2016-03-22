# Authors: Kelsey Meranda, Kim Forbes, Rosalyn Tan

all: scheme_parser

# compiles parser.y using bison into .tab and .output files
parser.tab.c parser.tab.h: parser.y
	bison -d -bparser -v parser.y

# compiles scanner.l and parser.tab.h into scanner.c
scanner.c: scanner.l parser.tab.h
	flex --noyywrap -o scanner.c scanner.l

%.o: %.c
	gcc -Wall -std=c99 -c $< -o $@

scheme_parser: parser.tab.o scanner.o main.o
	gcc -g -std=c99 parser.tab.o scanner.o main.o -o scheme_parser -lm

.PHONY: clean

clean:
	rm *~ parser.tab.* parser.output scheme_parser *.o scanner.c *.scheme_parser.out
