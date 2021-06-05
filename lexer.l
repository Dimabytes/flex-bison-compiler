%{
	#include "parser.tab.h"
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
%}

%%
"&&"				    { 	return and; 	}
"let"				    { 	return let; 	}
"||"				    { 	return or; 	}
"if"				    {	return IF;	}
"else"				    {	return ELSE;	}
"=="			  	    {	return eq;	}
"!="			  	    {	return ne;	}
"<="			        {	return le;	}
">="			  	    {	return ge;	}
"while"                 {   return WHILE;   }
"console.log"			{	return print;	}
","                     {   return comma;   }
[0-9]+				    {

					yylval.no=atoi(yytext) ;
					return num;
	                            }
[a-z]([a-z]|[0-9])*		    {
					strcpy(yylval.var,yytext);
					return id;
				    }
[ \t\n]					;
[- + ; ( ) * / = < > { } % ? : ]    {  return *yytext;  }
.				    {   printf("invalid code.");  }
%%


int yywrap()
{
return 1;
}


