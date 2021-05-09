%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	void yyerror(char *s);

	extern FILE *yyout;
	extern char *yylex();

	void installid(char s[],int n);    /* Enter symbol and corresponding value to  the symbol table */
	int getid(char s[]);		   /* Get the value associated with  an identifier */

	struct table
    	{
    		char name[10];
    		int val;
    	} symbol[53];
%}



%union{
	int no;
	char var[10];
}

    %token <var> id
	%token <no> num
	%token PRINT EXIT CONST
	%type <no> EXIT start exp term

	%start start


	%left '+' '-' '%'
	%left '*' '/'

%%

start	: EXIT ';'		{	exit(0);	}
	| PRINT exp ';'		{ printf("Printing: %d\n",$2); }
	| start PRINT exp ';'   { printf("Printing: %d\n",$3); }

	| id '=' exp ';' 	{ installid($1,$3); }

	| start id '=' exp ';' { installid($2,$4); }
	| start EXIT ';' { exit(EXIT_SUCCESS);}
	;


		/*<------------- TERMS ----------> */
term   	: num                {$$ = $1;}
	    | id			{$$=getid($1);}
;

		/*<-------------- EXPRESSION -----------> */
exp : term        { {$$ = $1;}               /*fprintf(yyout,"%s := %d + %d;\n ",reg[0],$1,$3);*/ ; }
    | exp '+' exp          { {$$ = $1 + $3;}               /*fprintf(yyout,"%s := %d + %d;\n ",reg[0],$1,$3);*/ ; }
    | exp '-' exp          { {$$ = $1 - $3;}               /*fprintf(yyout,"%s := %d - %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '*' exp	       { {$$ = $1 * $3;}               /*fprintf(yyout,"%s := %d * %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '/' exp	       { {$$ = $1 / $3;}               /*fprintf(yyout,"%s := %d / %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '%'exp		{ {$$ = $1 % $3;}}
	| '(' exp ')'		{ {$$ = $2;}                   /*fprintf(yyout,"%s := %d;\n ",reg[0],$2); */;}
	;


%%

void installid(char str[],int n)
{
	int index,i;
	index=str[0]%53;
	i=index;
	if(strcmp(str,symbol[i].name)==0||symbol[i].val==-101)
	{
		symbol[index].val=n;
		strcpy(symbol[index].name,str);
	}
	else
	{
		i=(i+1)%53;
 		while(i!=index)
		{
			if(strcmp(str,symbol[i].name)==0||symbol[i].val==-101)
			{
			    printf("NIHUYA");
				symbol[i].val=n;
				strcpy(symbol[i].name,str);
				break;
			}
			i=(i+1)%53;
		}
	}

}

int getid(char str[])
{
	int index,i;
	index=str[0]%53;
	i=index;
	if(strcmp(str,symbol[index].name)==0)
	{
		return(symbol[index].val);
	}
	else
	{
		i=(i+1)%53;
 		while(i!=index)
		{
			if(strcmp(str,symbol[i].name)==0)
			{
				return (symbol[i].val);
				break;
			}
			i=(i+1)%53;
		}
		if(i==index)
		{
			printf("not initialised.");
		}
	}

}

void yyerror (char *s)
{
	fprintf (stdout, "Error: %s\n", s);
}


int main()
{
    for(int i=0;i<53;i++)
	{
		symbol[i].val=-101;
		strcpy(symbol[i].name,"");
	}
 	return yyparse();
}
