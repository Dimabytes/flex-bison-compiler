build:
	bison -d parser.y
	flex lexer.l
	gcc -ll parser.tab.c lex.yy.c
	./a.out