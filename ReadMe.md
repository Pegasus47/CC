# 1. Generate parser (Bison)
bison -d part2.y

# 2. Generate lexer (Lex)
lex part2.l

# 3. Compile Bison output
gcc -Wall -Wno-unused-function -c part2.tab.c

# 4. Compile Flex output
cc lex.yy.c part2.tab.c -o program

# 5. Link everything
gcc -Wall -Wno-unused-function -o forth_parser part2.tab.o lex.yy.o -lfl
