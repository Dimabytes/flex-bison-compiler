%{
	#include "parser.tab.h"
	#include<string.h>
	#include <stdio.h>
	#include<stdlib.h>

%}

%%
"print"                 {   return PRINT;     }
"exit"			    	{	return EXIT;	}
"id"			    	{	return id;	}
"if"			    	{	return IF;	}
"else"			    	{	return ELSE ;	}
[0-9]+				    {
    yylval.no=atoi(yytext);
    return num;
}
[a-z]([a-z]|[0-9])*		    {
					strcpy(yylval.var,yytext);
					return id;
				    }
[ \t\n]					;
[- + ; ( ) * / = < > { } % ? : ]    {  return *yytext;  }
.				         {   printf("invalid char.");  }
%%


int yywrap()
{
return 1;
}


