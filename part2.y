%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int   yylex(void);
extern FILE *yyin;
void yyerror(const char *s);

static int temp_count  = 0;
static int label_count = 0;

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
    if (vtop >= MAX_VS - 1) { fprintf(stderr, "Error: value stack overflow\n"); exit(1); }
    vstack[++vtop] = s;
}

static char *vpop(void) {
    if (vtop < 0) { fprintf(stderr, "Error: value stack underflow\n"); return strdup("??"); }
    return vstack[vtop--];
}

#define MAX_LS 64
static char *lstack[MAX_LS];
static int   ltop = -1;

static void lpush(char *l) {
    if (ltop >= MAX_LS - 1) { fprintf(stderr, "Error: label stack overflow\n"); exit(1); }
    lstack[++ltop] = l;
}

static char *lpop(void) {
    if (ltop < 0) { fprintf(stderr, "Error: label stack underflow\n"); return strdup("??"); }
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

program
    : word_seq
    ;

word_seq
    : word_seq word
    | /* e */
    ;

if_marker
    : /* e */
    {
        char *cond   = vpop();
        char *l_else = new_label();
        printf("  ifFalse %s goto %s\n", cond, l_else);
        free(cond);
        lpush(l_else);          
    }
    ;

else_marker
    : /* e */
    {
        char *l_end  = new_label();
        char *l_else = lpop();  /* retrieve the label pushed by if_marker */
        printf("  goto %s\n",  l_end);
        printf("%s:\n",        l_else);
        free(l_else);
        lpush(l_end);           /* saved for THEN */
    }
    ;

begin_marker
    : /* e */
    {
        char *l = new_label();
        printf("%s:\n", l);
        lpush(l);               /* saved for REPEAT */
    }
    ;

word
    : NUMBER
    {
        char *buf = malloc(32);
        sprintf(buf, "%d", $1);
        vpush(buf);
    }

    | IDENTIFIER OP_FETCH
    {
        char *t = new_temp();
        printf("  %s = %s\n", t, $1);
        free($1);
        vpush(t);
    }

    | IDENTIFIER
    {
        vpush($1);              /* vstack owns $1 */
    }

    | OP_STORE
    {
        char *addr = vpop();
        char *val  = vpop();
        printf("  %s = %s\n", addr, val);
        free(addr);
        free(val);
    }

    | OP_PRINT
    {
        char *v = vpop();
        printf("  print %s\n", v);
        free(v);
    }

    | OP_PLUS
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s + %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_MINUS
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s - %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_MUL
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s * %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_DIV
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s / %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_MOD
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s MOD %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_DIVMOD
    {
        char *r  = vpop(), *l = vpop();
        char *t1 = new_temp(), *t2 = new_temp();
        printf("  %s = %s MOD %s\n", t1, l, r);
        printf("  %s = %s / %s\n",   t2, l, r);
        free(l); free(r);
        vpush(t1);              /*remainder is lower one, quotient is upper one*/
        vpush(t2);              
    }

    | OP_EQ
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s == %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_NEQ
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s != %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_LT
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s < %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_GT
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s > %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_LEQ
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s <= %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_GEQ
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s >= %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_AND
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s AND %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_OR
    {
        char *r = vpop(), *l = vpop();
        char *t = new_temp();
        printf("  %s = %s OR %s\n", t, l, r);
        free(l); free(r);
        vpush(t);
    }

    | OP_INVERT
    {
        char *v = vpop();
        char *t = new_temp();
        printf("  %s = INVERT %s\n", t, v);
        free(v);
        vpush(t);
    }

    | OP_ABS
    {
        char *v = vpop();
        char *t = new_temp();
        printf("  %s = ABS %s\n", t, v);
        free(v);
        vpush(t);
    }

    | OP_NEGATE
    {
        char *v = vpop();
        char *t = new_temp();
        printf("  %s = - %s\n", t, v);
        free(v);
        vpush(t);
    }

    | KW_VARIABLE IDENTIFIER
    {
        printf("  /* declare %s */\n", $2);
        free($2);
    }

    | KW_IF if_marker word_seq KW_THEN
    {
        char *l = lpop();
        printf("%s:\n", l);
        free(l);
    }

    | KW_IF if_marker word_seq KW_ELSE else_marker word_seq KW_THEN
    {
        char *l = lpop();
        printf("%s:\n", l);
        free(l);
    }

    | KW_BEGIN begin_marker word_seq KW_REPEAT
    {
        char *cond    = vpop();
        char *l_begin = lpop();
        printf("  ifTrue %s goto %s\n", cond, l_begin);
        free(cond);
        free(l_begin);
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "\n*** Syntax Error: %s ***\n", s);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if (!yyin) {
        fprintf(stderr, "Error: cannot open '%s'\n", argv[1]);
        return 1;
    }

    printf("=== Three-Address Code (TAC) Output ===\n\n");
    int result = yyparse();
    fclose(yyin);

    if (result == 0)
        printf("\n=== Parsing Successful ===\n");
    else
        printf("\n=== Parsing Failed ===\n");

    return result;
}
