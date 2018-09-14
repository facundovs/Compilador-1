%{
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "y.tab.h"
struct struct_tablaSimbolos{
	char nombre[100];
	char tipo[100];
	char valor[50];
	char longitud[100];
};

int guardar_TS(char*, char*);
int crear_TS();

int puntero_array = 0;
FILE  *yyin;
int yylval;
struct struct_tablaSimbolos tablaSimbolos[1000];

%}
%option noyywrap  
%option yylineno 

DIGITO			[0-9]
NUM_INT			({DIGITO})+
NUM_REAL		({DIGITO})+"."({DIGITO})*|({DIGITO})*"."({DIGITO})+
LETRA			[a-zA-Z]
CONST_STR               "({LETRA}|{DIGITO}|.)+"
COMENTARIO_SIMPLE		"-/"({LETRA}|{DIGITO}|_|" "|":"|"="|".")*"/-"
COMENTARIO_DOBLE		"-/"({LETRA}|{DIGITO}|_|" "|":"|"="|"."|{COMENTARIO_SIMPLE})*"/-"
CONST_REAL              {DIGITO}*"."{DIGITO}+
CONST_INT               {DIGITO}+
ID					{LETRA}({LETRA}|{DIGITO}|_)*
OP_COMPARACION          ["<"|"="|">"|"<="|">="|"><"]
OP_SURES                ["+"|"-"]
OP_MULTDIV              ["*"|"/"]
OP_ASIG   				[":="]
OP_DOSP   				[":"]
OP_AND					["AND"|"and"|"&&"]
OP_OR					["OR"|"or"|"||"]
OP_NOT					["NOT"|"not"]
CAR_COMA                   [","]
CAR_PUNTO                  ["."]
CAR_CA                     ["["]
CAR_CC                     ["]"]
CAR_PA                     ["("]
CAR_PC                     [")"]

%%
"program"		{ return PROGRAM;}
"DEFVAR"		{ return DEFVAR;}
"defvar"		{ return DEFVAR;}
"ENDDEF"		{ return ENDDEF;}
"enddef"		{ return ENDDEF;}
"beginp"		{ return BEGINP;}
"endp"			{ 					
					if (crear_TS() == 0)
						printf("No se pudo crear el archivo de tabla de símbolos\n");
					return ENDP; 	
				}
{COMENTARIO_DOBLE}	{  }
{COMENTARIO_SIMPLE}	{  }
"real"			{ return REAL;}
"REAL"			{ return REAL;}
"float"			{ return REAL;}
"FLOAT"			{ return REAL;}
"integer"		{ return INTEGER;}
"INTEGER"		{ return INTEGER;}
"INT"			{ return INTEGER;}
"string"		{ return STRING;}
"STRING"		{ return STRING;}
"if"			{ return IF;}
"IF"			{ return IF;}
"then"   		{ return THEN;}
"THEN"   		{ return THEN;}
"else"   		{ return ELSE;}
"ELSE"   		{ return ELSE;}
"endif"	      { return ENDIF;}
"ENDIF"	      { return ENDIF;}
"for"			{ return FOR;}
"to"		      { return TO;}
"do"	         	{ return DO;}
"endfor"		{ return ENDFOR;}
"while"	      {return WHILE;}
"in"	         	{return IN;}
"endw"  		{ return ENDW;}
"repeat"		{ return REPEAT;}
"until"		{ return UNTIL;}
":="			{ return OP_ASIG;}
"="                     { return OP_COMPARACION;}
"+"			{ return OP_SURES;}
"-"			{ return OP_SURES;}
"*"			{ return OP_MULTDIV;}
"/"			{ return OP_MULTDIV;}
"("			{ return CAR_PA;}
")"			{ return CAR_PC;}
">"                     { return OP_COMPARACION;}
">="                    { return OP_COMPARACION;}
"<"                     { return OP_COMPARACION;}
"<="                    { return OP_COMPARACION;}
"><"                    { return OP_COMPARACION;}
"="                     { return OP_COMPARACION;}
":"                     { return OP_DOSP;}
"&&"                   { return OP_AND;}
"AND"                   { return OP_AND;}
"and"                   { return OP_AND;}
"OR"                   { return OP_OR;}
"or"                   { return OP_OR;}
"||"                   { return OP_OR;}
"NOT"                   { return OP_NOT;}
"not"                   { return OP_NOT;}
{ID}			{ guardar_TS("ID", yytext); return ID; }
{CONST_INT}		{ return CONST_INT;}
{CONST_STR}		{ guardar_TS("CTE_STR", yytext); return CONST_STR;}
{CONST_REAL}	{ return CONST_REAL;}
{CAR_COMA}		{ return CAR_COMA;}
{CAR_PUNTO}		{ return CAR_PUNTO;}
{NUM_INT}	{ 
				int num = atoi(yytext); 
				if(num >= 0 && num <= 65535){
					guardar_TS("CTE_INT", yytext);
					return CONST_INT; 
				}else{
					printf("Error. Integer fuera de rango.\n");
					system ("Pause");
					exit(1);
				}
			}
{NUM_REAL}	{ 
				double num = atof(yytext);
				double cotaMayor = (3.4)*(exp(38));
				if(num >= 0 && num <= cotaMayor){
					guardar_TS("CTE_REAL", yytext);
					return CONST_REAL; 
				}else{
					printf("Error. Real fuera de rango.\n");
					system ("Pause");
					exit(2);
				}
			}

"\n"      		
"\t"		
" "
%%
int guardar_TS(char* tipo, char* nombre){
	//printf("tipo: %s   -   nombre: %s\n", tipo, nombre);
	int i;
	int retornar;
	for(i = 0; i < puntero_array; i++){
		if(strcmp(tablaSimbolos[i].nombre, nombre) == 0){
			//printf("lex: %s   -   tipo: %s   -   pos: %d\n", nombre, tipo, i);
			return i;
		}
	}
	strcpy(tablaSimbolos[puntero_array].tipo, tipo);
	strcpy(tablaSimbolos[puntero_array].nombre, nombre);
	retornar = puntero_array;
	puntero_array++;
	//printf("lex: %s   -   tipo: %s   -   pos: %d\n", nombre, tipo, i);
	return retornar;
}

int crear_TS(){
	FILE *pf; 
	int i;
	pf = fopen("ts.txt","w"); 

	if (!pf)
		return 0;

	fprintf(pf, "Nombre \t \t Tipo \t \t Valor \t \t Longitud\n");
	for (i = 0; i < puntero_array; i++)
		if (strcmp(tablaSimbolos[i].tipo, "ID") == 0 )  
			fprintf(pf,"%s\n", tablaSimbolos[i].nombre);
		else
			fprintf(pf,"_%s\n", tablaSimbolos[i].nombre);
	fclose(pf); 

	return 1;
}
