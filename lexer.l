%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"
extern YYSTYPE yylval;
%}

%%

 /*keywords*/ 
"IF"        {return KW_IF;}
"ELSE"      {return KW_ELSE;}
"THEN"      {return KW_THEN;}
"BEGIN"     {return KW_BEGIN;}
"REPEAT"    {return KW_REPEAT;}
"VARIABLE"  {return KW_VARIABLE;}

"\/MOD"      { return OP_DIVMOD;   }
"MOD"       { return OP_MOD;      }

 /*logical operators*/
"AND"       {return OP_AND;}
"OR"        {return OP_OR;}
"INVERT"    {return OP_INVERT;}
"ABS"       {return OP_ABS;}
"NEGATE"    {return OP_NEGATE;}

 /*relational operators*/ 
">="        {return OP_GEQ;}
"<="        {return OP_LEQ;}
"<>"        {return OP_NEQ;}
"="         {return OP_EQ;}
">"         {return OP_GT;}
"<"         {return OP_LT;}

 /*arithmetic operators 2*/
"+"         {return OP_PLUS;}
"-"         {return OP_MINUS;}
"*"         {return OP_MUL;}
"/"         {return OP_DIV;}

"!"         {return OP_STORE;}  /*assignment operator*/
"@"         {return OP_FETCH;}  /*address operator*/
"."         {return OP_PRINT;}  /*stack output word*/

 /*numbers*/
[0-9]+      {yylval.ival = atoi(yytext); return NUMBER;}

[_a-zA-Z][_a-zA-Z0-9-]* {
                yylval.sval = strdup(yytext);
                return IDENTIFIER;
            }

[ \t\n\r]+  { /*skip the spaces*/ }

.           {printf("Unknown token %s \n",yytext);}

%%

int yywrap(void) { return 1; }