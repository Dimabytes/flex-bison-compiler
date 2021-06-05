%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	void yyerror(char *s);

	char buffer[300];		   /* Temporary buffer to hold intermediate code  (written to file)*/
	void installid(char s[],int n);    /* Enter symbol and corresponding value to  the symbol table */
	int getid(char s[]);		   /* Get the value associated with  an identifier */
	int relop(int a, int b, int c);	   /* Performs relational operation and returns result */


	char reg[7][10]={"t1","t2","t3","t4","t5","t6"};   /* Temporaries for holding values for IR Code */


	extern FILE *yyout;  		/* Pointer to the output file */
	extern char *yylex();


	/* The Symbol Table containing name and value */
	struct table
	{
		char name[10];
		int val;
	} symbol[53];


%}



%union{
	int no;
	char var[10];
	char code[100];
      }


	%token <var> id
	%token <no> num
	%type <code>condn assignment statement while_statement
	%token print EXIT IF ELSE WHILE DEF comma let
	%type <no>  start exp  term



	%start start   /* Start Symbol of the Grammar */


	%left and or
	%left '>' '<' eq ne ge le '?' ':'
	%left '+' '-' '%'
	%left '*' '/'

%%



start	: EXIT ';'		{	exit(0);	}
	| print '(' exp ')' ';'		{
					sprintf(buffer, "printf(\"%%d\", %d)\n",$3);
					fprintf(yyout,"%s\n" , buffer);
				}
	| start print '(' exp ')' ';'   {
					sprintf(buffer, "printf(\"%%d\", %d)\n",$4);
					fprintf(yyout,"%s\n" , buffer);
				}
	| let id '=' exp ';' 	{
					 {installid($2,$4);}

					 sprintf(buffer,"int %s = %d;\n",$2,$4);

					 fprintf(yyout,"%s\n" , buffer);
				}

	| start let id '=' exp ';' {
					 {installid($3,$5);}
					 sprintf(buffer,"int %s = %d;\n",$3,$5);

					 fprintf(yyout,"%s\n" , buffer);
				}

    | id '=' exp ';' 	{
        					 {installid($1,$3);}

        					 sprintf(buffer,"%s = %d;\n",$1,$3);

        					 fprintf(yyout,"%s\n" , buffer);
        				}
    | start id '=' exp ';' {
					 {installid($2,$4);}
					 sprintf(buffer,"int %s = %d;\n",$2,$4);

					 fprintf(yyout,"%s\n" , buffer);
				}

	| condn			{
					 fprintf(yyout,"%s\n" , $1);
				}

	| start condn		{
					 fprintf(yyout,"%s\n" , $2);
				}
	| while_statement	{
					 fprintf(yyout,"%s\n" , $1);
				}

	| start while_statement {
					 fprintf(yyout,"%s\n" , $2);
				}

	| start EXIT ';'	{


					 exit(EXIT_SUCCESS);


				}

        			;
		/* <---------------- WHILE STATEMENT ---------------------------->   */

while_statement : WHILE '(' exp ')' '{' statement '}'
				{
					 sprintf(buffer,"while (%d) {\n%s}", $3, $6);
					 strcpy($$,buffer);
				}


		/* <----------------- IF AND IF-ELSE CONSTRUCT ------------->  */
condn :  IF '(' exp ')' '{' statement '}'
     				{
					sprintf(buffer,"if (%d) {\n%s}", $3, $6);
					strcpy($$,buffer);
				}
	  |	 IF '(' exp ')'  '{' statement '}' ELSE '{' statement '}'
			        {
				     sprintf(buffer,"if (%d) {\n%s} else {\n%s\n}", $3, $6, $10);
				     strcpy($$,buffer);
				}
				;


		/*<----------- STATEMENTS ---------------------> */

statement : assignment statement
	  			{
					 strcat($1,$2);
					 strcpy($$,$1);
			        }
			|	assignment		{ { strcpy($$,$1); } }
			| condn statement {  strcat($1,$2); strcpy($$,$1); }
			|	condn		{ { strcpy($$,$1); } }
			|';' { strcpy($$,"");	}
			;

		/* <------------ ASSIGNMENT STATEMENT ---------> */

assignment : let id '=' exp ';' { {installid($2,$4);} sprintf(buffer,"int %s = %d;\n",$2,$4); strcpy($$,buffer); }
            | id '=' exp ';' { {installid($1,$3);} sprintf(buffer,"%s = %d;\n",$1,$3); strcpy($$,buffer); }


		/*<-------------- EXPRESSION -----------> */
exp    	: term                 { {$$ = $1;}                    /*fprintf(yyout,"%s := %d;\n ",reg[0],$1);*/ ; }
       	| exp '+' exp          { {$$ = $1 + $3;}               /*fprintf(yyout,"%s := %d + %d;\n ",reg[0],$1,$3);*/ ; }
       	| exp '-' exp          { {$$ = $1 - $3;}               /*fprintf(yyout,"%s := %d - %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '*' exp	       { {$$ = $1 * $3;}               /*fprintf(yyout,"%s := %d * %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '/' exp	       { {$$ = $1 / $3;}               /*fprintf(yyout,"%s := %d / %d;\n ",reg[0],$1,$3);*/ ; }
	| exp '%'exp		{ {$$= $1 % $3;}}
	| exp '>' exp		{ {$$ =relop($1,$3,1);}        /*fprintf(yyout,"%s := %c > %d;\n ",reg[0],$1,$3); */; }
	| exp '<' exp		{ {$$ =relop($1,$3,2);}        /*fprintf(yyout,"%s := %c < %d;\n ",reg[0],$1,$3); */; }
	| exp eq exp		{ {$$ =relop($1,$3,3);}        /*fprintf(yyout,"%s := %c eq %d;\n ",reg[0],$1,$3); */;}
	| exp ne exp		{ {$$ =relop($1,$3,4);}	       /*fprintf(yyout,"%s := %c neq %d;\n ",reg[0],$1,$3); */;}
	| exp ge exp		{ {$$ =relop($1,$3,5);}	       /*fprintf(yyout,"%s := %c ge %d;\n ",reg[0],$1,$3); */;}
	| exp le exp		{ {$$ =relop($1,$3,6);}        /*fprintf(yyout,"%s := %c le %d;\n ",reg[0],$1,$3); */;}
	| '(' exp ')'		{ {$$ = $2;}                   /*fprintf(yyout,"%s := %d;\n ",reg[0],$2); */;}
	| exp and exp		{ {$$ =relop($1,$3,7);}        /*fprintf(yyout,"%s := %c and %d;\n ",reg[0],$1,$3);*/ ;}
	| exp or exp		{ {$$ =relop($1,$3,8);}        /*fprintf(yyout,"%s := %c or %d;\n ",reg[0],$1,$3);*/ ;}
	;


		/*<------------- TERMS ----------> */
term   	: num                {$$ = $1;}
	|id			{$$=getid($1);}
;

%%



			/*         END OF RULES SECTION		 */





	/*  FOR PERFORMING RELATIONAL OPERATIONS */

int relop(int a , int b ,int op)
{
	switch(op)
	{
		case 1:if(a>b){return 1;} else{return 0;} break;
		case 2:if(a<b){return 1;} else{return 0;} break;
		case 3:if(a==b){return 1;} else{return 0;} break;
		case 4:if(a!=b){return 1;} else{return 0;} break;
		case 5:if(a>=b){return 1;} else{return 0;} break;
		case 6:if(a<=b){return 1;} else{return 0;} break;
		case 7:if(a>0 && b>0 ){return 1;}else{return 0;}break;
		case 8:if(a>0 || b>0 ){return 1;}else{return 0;}break;
	}
}

	/*  FOR INSERTING VALUE INTO THE SYMBOL TABLE   */
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

	yyout = fopen("output.c","a");


 	return yyparse();

}
