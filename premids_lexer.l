%{
#include<stdio.h>
%}


%%
IF|ELSE|THEN|BEGIN|REPEAT|VARIABLE	{printf("Keyword: %s\n", yytext);}
MOD|\/MOD				{printf("Arithmetic Operator: %s\n", yytext);}
[+\-*/]					{printf("Arithmetic Operator: %s\n", yytext);}
>=|<=|<>|=|>|<				{printf("Relational Operator: %s\n", yytext);}
AND|OR|INVERT|ABS|NEGATE		{printf("Logical Operator: %s\n", yytext);}
[0-9]+					{printf("Number: %s\n", yytext);}
[_a-zA-Z][_a-zA-Z0-9\-]*		{printf("Identifier: %s\n", yytext);}
!					{printf("Assignment Operator: %s\n", yytext);}
\.					{printf("Stack Output Word: %s\n", yytext);}
\@					{printf("Address Operator: %s\n", yytext);}
[ \t\n\r]+				;
.					{printf("Unknown token %s \n",yytext);}
 						
%%
int main()
{
//Please edit the next line to either receive wrongCode.txt or sample.txt as the input file
yyin = fopen("wrongCode.txt", "r");
yylex();
return 0;
}
