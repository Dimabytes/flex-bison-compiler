%{
	#include "parser.tab.h"
	#include<string.h>
	#include <stdio.h>
	#include<stdlib.h>

%}

%%
"print"                 {   return PRINT;     }
"exit"			    	{	return EXIT;	}
[0-9]+				    {
    yylval.no=atoi(yytext);
    return num;
}
[ \t\n]					;
[- + ; ( ) * / = < > { } % ? : ]    {  return *yytext;  }
.				         {   printf("invalid char.");  }
%%


int yywrap()
{
return 1;
}


