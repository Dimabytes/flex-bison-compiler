%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	void yyerror(char *s);
    void itoa(int n, char s[]);
	char buffer[300];
	extern FILE *yyout;  		/* Pointer to the output file */
	extern char *yylex();
	struct symbol
	{
		char name[10];
		int val;
	} symbol[53];


%}



%union{
	    int no;
	    char var[100];
	    char code[100];
    }


	%token <var> id
	%token <no> num
	%type <code>condn assignment statement while_statement print_statement
	%token print EXIT IF ELSE WHILE DEF comma let
	%type <var>  start exp  term



	%start start   /* Start Symbol of the Grammar */

	%left and or
	%left '>' '<' eq ne ge le '?' ':'
	%left '+' '-' '%'
	%left '*' '/'

%%



start : print '(' exp ')' ';'		{
					sprintf(buffer, "printf(\"%%d\", %s);\n",$3);
					fprintf(yyout,"%s\n" , buffer);
				}
	| start print '(' exp ')' ';'   {
					sprintf(buffer, "printf(\"%%d\", %s);\n",$4);
					fprintf(yyout,"%s\n" , buffer);
				}
	| let id '=' exp ';' 	{

					 sprintf(buffer,"int %s = %s;\n",$2,$4);

					 fprintf(yyout,"%s\n" , buffer);
				}

	| start let id '=' exp ';' {
					 sprintf(buffer,"int %s = %s;\n",$3,$5);

					 fprintf(yyout,"%s\n" , buffer);
				}

    | id '=' exp ';' 	{

        					 sprintf(buffer,"%s = %s;\n",$1,$3);

        					 fprintf(yyout,"%s\n" , buffer);
        				}
    | start id '=' exp ';' {
					 sprintf(buffer,"int %s = %s;\n",$2,$4);

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
        			;

		/* <------------- PRINT STATEMENT -------------> */

print_statement : print '(' exp ')' ';' {
                    sprintf(buffer, "printf(\"%%d\", %s);\n",$3);
  					strcpy($$,buffer);
  }

		/* <---------------- WHILE STATEMENT ---------------------------->   */

while_statement : WHILE '(' exp ')' '{' statement '}'
				{
					 sprintf(buffer,"while (%s) {\n%s}", $3, $6);
					 strcpy($$,buffer);
				}

		/* <----------------- IF AND IF-ELSE CONSTRUCT ------------->  */


condn :  IF '(' exp ')' '{' statement '}'
     				{
					sprintf(buffer,"if (%s) {\n%s}", $3, $6);
					strcpy($$,buffer);
				}
	  |	 IF '(' exp ')'  '{' statement '}' ELSE '{' statement '}'
			        {
				     sprintf(buffer,"if (%s) {\n%s} else {\n%s}", $3, $6, $10);
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
			| print_statement statement {  strcat($1,$2);  strcpy($$,$1); }
            | print_statement { {strcpy($$,$1);} }
			|	condn		{ { strcpy($$,$1); } }
			|';' { strcpy($$,"");	}
			;

		/* <------------ ASSIGNMENT STATEMENT ---------> */

assignment : let id '=' exp ';' { sprintf(buffer,"int %s = %s;\n",$2,$4); strcpy($$,buffer); }
            | id '=' exp ';' { sprintf(buffer,"%s = %s;\n",$1,$3); strcpy($$,buffer); }


		/*<-------------- EXPRESSION -----------> */
exp    	: term                 { strcpy($$,$1); }
       	| exp '+' exp          { sprintf(buffer,"%s + %s", $1, $3); strcpy($$,buffer)}
       	| exp '-' exp          { sprintf(buffer,"%s - %s", $1, $3); strcpy($$,buffer)}
       	| exp '*' exp          { sprintf(buffer,"%s * %s", $1, $3); strcpy($$,buffer)}
       	| exp '/' exp          { sprintf(buffer,"%s / %s", $1, $3); strcpy($$,buffer)}
       	| exp '>' exp          { sprintf(buffer,"%s > %s", $1, $3); strcpy($$,buffer)}
       	| exp '<' exp          { sprintf(buffer,"%s < %s", $1, $3); strcpy($$,buffer)}
       	| exp '%' exp          { sprintf(buffer,"%s %% %s", $1, $3); strcpy($$,buffer)}
        | exp eq exp		   { sprintf(buffer,"%s == %s", $1, $3); strcpy($$,buffer)}
        | exp ne exp		   { sprintf(buffer,"%s != %s", $1, $3); strcpy($$,buffer)}
        | exp ge exp		   { sprintf(buffer,"%s >= %s", $1, $3); strcpy($$,buffer)}
        | exp le exp		   { sprintf(buffer,"%s <= %s", $1, $3); strcpy($$,buffer)}
        | '(' exp ')'		   { sprintf(buffer,"(%s)", $2); strcpy($$,buffer)}
        | exp and exp		   { sprintf(buffer,"%s && %s", $1, $3); strcpy($$,buffer)}
        | exp or exp		   { sprintf(buffer,"%s || %s", $1, $3); strcpy($$,buffer)}

	;


		/*<------------- TERMS ----------> */
term   	: num                {itoa($1, buffer); strcpy($$,buffer)}
	|id			{strcpy($$,$1)}
;

%%

 void reverse(char s[])
 {
     int i, j;
     char c;

     for (i = 0, j = strlen(s)-1; i<j; i++, j--) {
         c = s[i];
         s[i] = s[j];
         s[j] = c;
     }
 }

 void itoa(int n, char s[])
 {
     int i, sign;

     if ((sign = n) < 0)  /* записываем знак */
         n = -n;          /* делаем n положительным числом */
     i = 0;
     do {       /* генерируем цифры в обратном порядке */
         s[i++] = n % 10 + '0';   /* берем следующую цифру */
     } while ((n /= 10) > 0);     /* удаляем */
     if (sign < 0)
         s[i++] = '-';
     s[i] = '\0';
     reverse(s);
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
