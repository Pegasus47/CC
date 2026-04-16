#!/bin/bash
set -e

echo "🔧 Generating parser..."
bison -d parser.y

echo "🔧 Generating lexer..."
lex lexer.l

echo "🔧 Compiling..."
gcc -Wall -Wno-unused-function parser.tab.c lex.yy.c -o program -lfl

echo "🚀 Running program (using sample.txt)..."
./program

echo "✅ Done. Check output.txt"a