%{
	#include "parser.tab.h"
	#include<string.h>
	#include <stdio.h>
	#include<stdlib.h>

	/*
		This is the code block where we can write header files and other C functions which we need to implement
	*/

%}
	/*
		Enclosed betweeen %%..%% are the rules  for matching the tokens which we need .
		A rule is written  in the form of a regular expression  followed by the action which is written in curly braces .
		In this case it returns constants which find their  value from the "parser.tab.h" header file
		( constants like and IF used in rules) .

		Detailed expressions for regualar expressions can be found in the dragon book (Compiler Principles Tools & Techniques).

	*/

%%
"&&"				    { 	return and; 	}
"let"				    { 	return let; 	}
"||"				    { 	return or; 	}
"if"				    {	return IF;	}
"else"				    {	return ELSE;	}
"=="			  	    {	return eq;	}
"!="			  	    {	return ne;	}
"<="			            {	return le;	}
">="			  	    {	return ge;	}
"while"                             {   return WHILE;   }
"console.log"			 	    {	return print;	}
","                                 {   return comma;   }
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
.				    {   printf("invalid char.");  }
%%


int yywrap()
{
return 1;
}


