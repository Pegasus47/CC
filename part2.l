%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "part2.tab.h"
extern YYSTYPE yylval;
%}

%%

"IF"        { return KW_IF;       }
"ELSE"      { return KW_ELSE;     }
"THEN"      { return KW_THEN;     }
"BEGIN"     { return KW_BEGIN;    }
"REPEAT"    { return KW_REPEAT;   }
"VARIABLE"  { return KW_VARIABLE; }

"\/MOD"      { return OP_DIVMOD;   }
"MOD"       { return OP_MOD;      }

"AND"       { return OP_AND;      }
"OR"        { return OP_OR;       }
"INVERT"    { return OP_INVERT;   }
"ABS"       { return OP_ABS;      }
"NEGATE"    { return OP_NEGATE;   }

">="        { return OP_GEQ;      }
"<="        { return OP_LEQ;      }
"<>"        { return OP_NEQ;      }
"="         { return OP_EQ;       }
">"         { return OP_GT;       }
"<"         { return OP_LT;       }

"+"         { return OP_PLUS;     }
"-"         { return OP_MINUS;    }
"*"         { return OP_MUL;      }
"/"         { return OP_DIV;      }

"!"         { return OP_STORE;    }
"@"         { return OP_FETCH;    }
"."         { return OP_PRINT;    }

[0-9]+      {
                yylval.ival = atoi(yytext);
                return NUMBER;
            }

[_a-zA-Z][_a-zA-Z0-9-]* {
                yylval.sval = strdup(yytext);
                return IDENTIFIER;
            }

[ \t\n\r]+  { /*skip the spaces*/ }

.           {
                fprintf(stderr, "Lexical error: unknown token '%s'\n", yytext);
            }

%%

int yywrap(void) { return 1; }
