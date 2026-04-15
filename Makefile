CC      = gcc
CFLAGS  = -Wall -Wno-unused-function

all: forth_parser

forth_parser: part2.tab.o lex.yy.o
	$(CC) $(CFLAGS) -o forth_parser part2.tab.o lex.yy.o -lfl

part2.tab.c part2.tab.h: part2.y
	bison -d part2.y

lex.yy.c: part2.l part2.tab.h
	flex part2.l

part2.tab.o: part2.tab.c
	$(CC) $(CFLAGS) -c part2.tab.c

lex.yy.o: lex.yy.c
	$(CC) $(CFLAGS) -c lex.yy.c

clean:
	rm -f forth_parser *.o lex.yy.c part2.tab.c part2.tab.h

test_valid:
	@echo "=== Running valid_input.fth ==="
	./forth_parser valid_input.fth

test_error:
	@echo "=== Running syntax_error.fth ==="
	./forth_parser syntax_error.fth; true
