%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int   yylex(void);
extern FILE *yyin;
void yyerror(const char *s);

static FILE *output_file = NULL;  

static int temp_count  = 0;
static int label_count = 0;

static char *symtab[100];
static int   symcount = 0;

static int sym_exists(const char *name) {
    for (int i = 0; i < symcount; i++)
        if (strcmp(symtab[i], name) == 0) return 1;
    return 0;
}

static void sym_declare(const char *name) {
    if (symcount >= 100) { 
        fprintf(stderr, "symbol table full"); 
        exit(1); 
    }
    if (sym_exists(name)) {
        printf("already declared\n");
        return;
    }
    symtab[symcount++] = strdup(name);
}

static char *new_temp(void) {
    char *t = malloc(16);
    sprintf(t, "t%d", temp_count++);
    return t;
}

static char *new_label(void) {
    char *l = malloc(16);
    sprintf(l, "L%d", label_count++);
    return l;
}

#define MAX_VS 256
static char *vstack[MAX_VS];
static int   vtop = -1;

static void vpush(char *s) {
    if (vtop >= MAX_VS - 1) { fprintf(stderr, "value stack overflow\n"); exit(1); }
    vstack[++vtop] = s;
}

static char *vpop(void) {
    if (vtop < 0) { 
        fprintf(stderr, "value stack underflow\n"); 
        return strdup("??"); 
    }
    return vstack[vtop--];
}

#define MAX_LS 64
static char *lstack[MAX_LS];
static int   ltop = -1;

static void lpush(char *l) {
    if (ltop >= MAX_LS - 1) { 
        fprintf(stderr, "label stack overflow\n"); 
        exit(1); 
    }
    lstack[++ltop] = l;
}

static char *lpop(void) {
    if (ltop < 0) { 
        fprintf(stderr, "label stack underflow\n"); 
        return strdup("??"); 
    }
    return lstack[ltop--];
}
%}

%union {
    char *sval;
    int   ival;
}

%token <sval> IDENTIFIER
%token <ival> NUMBER
%token KW_VARIABLE KW_IF KW_ELSE KW_THEN KW_BEGIN KW_REPEAT
%token OP_STORE OP_FETCH OP_PRINT
%token OP_PLUS  OP_MINUS OP_MUL OP_DIV OP_MOD OP_DIVMOD
%token OP_EQ  OP_NEQ  OP_LT  OP_GT  OP_LEQ  OP_GEQ
%token OP_AND OP_OR OP_INVERT OP_ABS OP_NEGATE

%%

program : word_seq ;

word_seq : word_seq word | /* e */ ;

if_marker : /* e */
    {
        char *cond   = vpop();
        char *l_else = new_label();
        fprintf(output_file, "  ifFalse %s goto %s\n", cond, l_else);
        free(cond);
        lpush(l_else);
    } ;

else_marker : /* e */
    {
        char *l_end  = new_label();
        char *l_else = lpop();  
        fprintf(output_file, "  goto %s\n",  l_end);
        fprintf(output_file, "%s:\n",        l_else);
        free(l_else);
        lpush(l_end);           
    };

begin_marker : /* e */
    {
        char *l = new_label();
        fprintf(output_file, "%s:\n", l);
        lpush(l);               
    };

word : NUMBER
    {
        char *buf = malloc(32);
        sprintf(buf, "%d", $1);
        vpush(buf);
    } | IDENTIFIER OP_FETCH {
        char *t = new_temp();
        fprintf(output_file, "  %s = %s\n", t, $1);
        free($1);
        vpush(t);
    } | IDENTIFIER {
        if (!sym_exists($1))
            fprintf(stderr, "Warning: '%s' used before declaration\n", $1);
        vpush($1);             
    } | OP_STORE {
        char *addr = vpop();
        char *val  = vpop();
        fprintf(output_file, "  %s = %s\n", addr, val);
        free(addr);
        free(val);
    } | OP_PRINT {
        char *v = vpop();
        fprintf(output_file, "  print %s\n", v);
        free(v);
    } | OP_PLUS {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s + %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_MINUS {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s - %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_MUL {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s * %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_DIV {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s / %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_MOD {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s MOD %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_DIVMOD {
        char *r  = vpop(), *l = vpop();
        char *t1 = new_temp(), *t2 = new_temp();
        fprintf(output_file, "  %s = %s MOD %s\n", t1, l, r);
        fprintf(output_file, "  %s = %s / %s\n",   t2, l, r);
        free(l); free(r);
        vpush(t1);               
        vpush(t2);
    } | OP_EQ {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s == %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_NEQ {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s != %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_LT {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s < %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_GT {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s > %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_LEQ {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s <= %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_GEQ {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s >= %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_AND {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s AND %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_OR {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = %s OR %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    } | OP_INVERT {
        char *v = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = INVERT %s\n", t, v);
        free(v);
        vpush(t);
    } | OP_ABS {
        char *v = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = ABS %s\n", t, v);
        free(v);
        vpush(t);
    } | OP_NEGATE {
        char *v = vpop();
        char *t = new_temp();
        fprintf(output_file, "  %s = - %s\n", t, v);
        free(v);
        vpush(t);
    } | KW_VARIABLE IDENTIFIER {
        sym_declare($2);
        fprintf(output_file,"  /* declare %s */\n", $2);
        free($2);
    } | KW_IF if_marker word_seq KW_THEN {
        char *l = lpop();
        fprintf(output_file, "%s:\n", l);
        free(l);
    } | KW_IF if_marker word_seq KW_ELSE else_marker word_seq KW_THEN {
        char *l = lpop();
        fprintf(output_file, "%s:\n", l);
        free(l);
    } | KW_BEGIN begin_marker word_seq KW_REPEAT {
        char *cond    = vpop();
        char *l_begin = lpop();
        fprintf(output_file, "  ifTrue %s goto %s\n", cond, l_begin); 
        free(cond);
        free(l_begin);
    } ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    yyin = fopen("syntax_error.fth", "r");
    output_file = fopen("output.txt", "w");

    fprintf(output_file, "three address codes: \n");
    int result = yyparse();

    fclose(yyin);

    if (result == 0){
        fprintf(output_file, "Parsing Successful. \n");
        printf("Parsing Successful. \n");

    }
    else{
        fprintf(output_file, "Parsing Failed.\n");
        printf("Parsing Failed. \n");
    }
    fclose(output_file);
    return result;
}
