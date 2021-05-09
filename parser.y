%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	void yyerror(char *s);

	extern FILE *yyout;  		/* Pointer to the output file */
	extern char *yylex();
%}



%union{
	int no;
}

	%token <no> num
	%token PRINT EXIT
	%type <no> EXIT start exp

	%start start   /* Start Symbol of the Grammar */



	/*
		Bison Specific commands
		%left  :  Left Associativity
	  	%right :  Right Associativity

	*/

	%left '+' '-' '%'
	%left '*' '/'

%%

start	: EXIT ';'		{	exit(0);	}
	| PRINT exp ';'		{
					printf("Printing: %d\n",$2);
				}
	| start PRINT exp ';'   {
					printf("Printing: %d\n",$3);
				}

	| start EXIT ';' {
        exit(EXIT_SUCCESS);
				}
				;


		/*<-------------- EXPRESSION -----------> */
exp : num        { {$$ = $1;}               /*fprintf(yyout,"%s := %d + %d;\n ",reg[0],$1,$3);*/ ; }
    | exp '+' exp          { {$$ = $1 + $3;}               /*fprintf(yyout,"%s := %d + %d;\n ",reg[0],$1,$3);*/ ; }
    | exp '-' exp          { {$$ = $1 - $3;}               /*fprintf(yyout,"%s := %d - %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '*' exp	       { {$$ = $1 * $3;}               /*fprintf(yyout,"%s := %d * %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '/' exp	       { {$$ = $1 / $3;}               /*fprintf(yyout,"%s := %d / %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '%'exp		{ {$$ = $1 % $3;}}
	| '(' exp ')'		{ {$$ = $2;}                   /*fprintf(yyout,"%s := %d;\n ",reg[0],$2); */;}
	;


%%

void yyerror (char *s)
{
	fprintf (stdout, "Error: %s\n", s);
}


int main()
{
 	return yyparse();
}
