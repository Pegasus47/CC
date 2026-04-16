# 1. Generate parser (Bison)
bison -d part2.y

# 2. Generate lexer (Lex)
lex part2.l

# 3. Compile Bison output
gcc -Wall -Wno-unused-function -c part2.tab.c

# 4. Compile Lex output and Link everything
cc lex.yy.c part2.tab.c -o program

# 6. Running the final code
./program <filename>
