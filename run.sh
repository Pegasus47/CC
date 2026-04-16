#!/bin/bash
set -e

bison -d parser.y

lex lexer.l

gcc -Wall -Wno-unused-function parser.tab.c lex.yy.c -o program -lfl

./program

echo "Done. Check output.txt"