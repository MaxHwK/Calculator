;--------------------------------------------------------------
;	PROJET ASSEMBLEUR CALCULATRICE		EL ABBOUNI / GIRON
;--------------------------------------------------------------

.model tiny

    	code segment
    
    	org 100h

DEBUT:

;-----------------------------------
;	MESSAGES BIENVENUE / SAISIE
;-----------------------------------

	MOV DX,OFFSET MESSBVN
	MOV AH,9
	INT 21H
	
	MOV DX,OFFSET MESS1
	MOV AH,9
	INT 21H

	JMP START

;-----------------------------------
;	INITIALISATION DES VARIABLES 
;-----------------------------------

NB1 DW 0                ;Initialisation des variables (nombre 1 et 2)
NB2 DW 0
OPERATEUR DB ?          ;Correspond à l'opérateur choisi

RESUL DW ?              ;Correspond au résultat de l'opération
SIGNE DB "+"            ;Initialisation de l'opérateur "+"

COMPTEUR DB 0           ;Initialisation du compteur pour la pile

;-----------------------------------
;	MACRO POUR SAUT DE LIGNE
;-----------------------------------

CRLF MACRO              
    MOV DL,0DH
    MOV AH,02H
    INT 21H
    MOV DL,0AH
    INT 21H    
ENDM

;-----------------------------------
;	DEBUT DU PROGRAMME
;-----------------------------------

START:
		
;--------------------------------------------
;	LECTURE ET AFFICHAGE DU PREMIER NOMBRE
;--------------------------------------------	
	
	MOV AH, 1       		;Début d'entête
	INT 21H

	XOR AH, AH      		;Rôle de "contrôle", un XOR inverse les chiffres en binaire : 101 --> 010, deux XOR permet de vérifier s'il y a un problème

	CMP AX, 13      		;13 : code ASCII de la touche "Entrée"
	JE SUITE        		;Si "Entrée", alors jump à SUITE

	;CHECK COMPTEUR <4  	;Le compteur doit être inférieur à 4 car on travaille sur 4 digits
	CMP COMPTEUR, 4     	;Si le compteur est égal à 4 digits, on jump à START
	JGE START
    
	CMP AX, 30H         	;30H = 0 en décimal, 39H = 9 en décimal, et il faut un chiffre compris entre 0 et 9
	JB START            	;Jump Below : si AX < 30H (0) 
    
	CMP  AX, 39H
	JG START            	;Jump Greater : si AX > 39H (9)
    
	XOR CX, CX
    
	MOV CL, AL 
    
	MOV AX, NB1         
	MOV BX, 0AH        		;Affichage de NB1
	XOR DX, DX
    
	MUL BX             		;Multiplication (schéma de Honner)
    
	MOV BX, 30H        		;Conversion en hexa
	SUB CX, BX         		;Retirer 30H (reconvertit en décimal)
    
	ADD AX, CX         		;Additionne la valeur stockée dans CX à celle de AX
    
	MOV NB1, AX
    
	INC COMPTEUR       		;Incrémentation du compteur (car on a retiré des choses du compteur)
    
    
    	
	JMP START
    
SUITE:

	MOV DX,OFFSET MESSOP
	MOV AH,9
	INT 21H
	
	CRLF               
    
	MOV AH, 1          
	INT 21H 
    
	XOR AH, AH
    
	CMP AX, "*"
	JB SUITE
    
	CMP AX, "/"
	JG SUITE
    
	CMP AX, 44        		;Si chose rentrée non comprise entre code ASCII 44 et 46 alors jump equal à suite
	JE SUITE
	CMP AX, 46
	JE SUITE
    
	MOV OPERATEUR, AL  		;Opérateur placé dans le registre AL
    
	CRLF
    
	MOV COMPTEUR, 0
    
;--------------------------------------------
;	LECTURE ET AFFICHAGE DU DEUXIEME NOMBRE
;--------------------------------------------
   
   	MOV DX,OFFSET MESS2
	MOV AH,9
	INT 21H 
   
L_NB2:  
	         	
	MOV AH, 1
	INT 21H
    
	XOR AH, AH
    
	CMP AX, 13            
	JE OPERATION  
    
	;CHECK COMPTEUR <4
	CMP COMPTEUR, 4
	JGE L_NB2
    
	CMP AX, 30H
	JB L_NB2
    
	CMP  AX, 39H
	JG L_NB2
    
	XOR CX, CX
    
	MOV CL, AL
    
	MOV AX, NB2
	MOV BX, 0AH
	XOR DX, DX
    
	MUL BX
    
	MOV BX, 30H
	SUB CX, BX
    
	ADD AX, CX
    
	MOV NB2, AX
    
	INC COMPTEUR
    
	JMP L_NB2    
	
;-----------------------------------
;	LISTE DES OPERATEURS
;-----------------------------------    
    
OPERATION: 
 
   	CMP OPERATEUR, "+"
   	JE DO_ADD
   
   	CMP OPERATEUR, "-"
   	JE DO_SUB
   
   	CMP OPERATEUR, "/"
   	JE DO_DIV
   
   	CMP OPERATEUR, "*"
   	JE DO_MUL
   
   	JMP ENDPROG
   
;-----------------------------------
;	ADDITION
;-----------------------------------   
   
DO_ADD:
	MOV AX, NB1
	ADD AX, NB2
    
	MOV RESUL, AX
    
	JMP DECOMP  

;-----------------------------------
;	SOUSTRACTION
;-----------------------------------
   
DO_SUB:
	MOV AX, NB1
    
	CMP AX, NB2
	JB SUB_M        			;Si NB2 > NB1 alors résultat négatif et jump below dans SUB_M 
    
	SUB AX, NB2
	MOV RESUL, AX
    
	JMP DECOMP
    
SUB_M:                			;Indicateur nombre négatif
	MOV SIGNE, "-"
	MOV AX, NB2
	SUB AX, NB1
	MOV RESUL, AX
    
	JMP DECOMP

;-----------------------------------
;	DIVISION
;-----------------------------------

DO_DIV:
	CMP NB2, 0
	JE  DIV_ERROR
    
	MOV AX, NB1
	DIV NB2
	MOV RESUL, AX
    
	JMP DECOMP

;-----------------------------------
;	AFFICHAGE ERREUR
;-----------------------------------

DIV_ERROR:
	CRLF
	 
	MOV AH, 2
	MOV DL, "E"
	INT 21H
    
	MOV AH, 2
	MOV DL, "R"
	INT 21H
    
	MOV AH, 2
	MOV DL, "R"
	INT 21H
    
	MOV AH, 2
	MOV DL, "E"
	INT 21H
    
	MOV AH, 2
	MOV DL, "U"
	INT 21H
	
	MOV AH, 2
	MOV DL, "R"
	INT 21H

	JMP ENDPROG
    
;-----------------------------------
;	MULTIPLICATION
;-----------------------------------  
    
DO_MUL:
	CRLF
    
	MOV AX, NB1
	MUL NB2 			;Resultat sur DX:AX
    
	MOV BX, 10000 		;Resultat: DX poid fort, AX poid faible
	DIV BX
    
	MOV SI, AX
	MOV DI, DX
    
	MOV COMPTEUR, 0
	MOV BX, 10
	MOV AX, DI
    
;-----------------------------------
;	DECOMPOSITION DE LA DIVISION
;-----------------------------------

DECOMP_DI:
	CMP AX, 0
	JE DECOMP_TEST_SI

MID_DECOMP_DI:                                  
	XOR DX, DX
    
	DIV BX
	PUSH DX
	INC COMPTEUR
    
	JMP DECOMP_DI
    
DECOMP_TEST_SI:   
	CMP SI, 0
	JE PRINT
    
	CMP COMPTEUR, 4
	JGE DECOMP_SI   	 
    
	JMP MID_DECOMP_DI
    
DECOMP_SI:
	MOV AX, SI
    
L_DECOMP_SI:     
	XOR DX, DX
    
	CMP AX, 0
	JE PRINT
    
	DIV BX
	PUSH DX
	INC COMPTEUR
    
	JMP L_DECOMP_SI
 
DECOMP:
	MOV COMPTEUR, 0
	MOV AX, RESUL
	MOV BX, 10

L_DECOMP:
	XOR DX, DX
    
	CMP AX, 0
	JE PRINT
    
	DIV BX
	PUSH DX
	INC COMPTEUR
    
	JMP L_DECOMP
    
PRINT:
	CRLF
    
	CMP SIGNE, "-"
	JNE PRINT_S
    
	MOV AH, 2
	MOV DL, SIGNE
	INT 21H

PRINT_S:
	MOV AH, 2
    
	CMP COMPTEUR, 0
	JE NB_NUL
 
L_PRINT:
	CMP COMPTEUR, 0
	JE ENDPROG    
    
	POP DX
	ADD DX, 30H
	INT 21H
	DEC COMPTEUR
    
	JMP L_PRINT
    
;-----------------------------------
;	CAS NULLE
;-----------------------------------

NB_NUL:
	MOV DL, "0"
	INT 21H
	
;-----------------------------------
;	FIN DU PROGRAMME
;-----------------------------------


	
ENDPROG:

MOV DX,OFFSET MESSRES
	MOV AH,9
	INT 21H 
	    
	MOV	AX, 4C00H
	INT 21H
	
;-----------------------------------
;	MESSAGES
;-----------------------------------	
	
	MESSBVN DB "Bienvenue sur notre projet d' Assembleur : Calculatrice programmé par EL ABBOUNI Elias et GIRON Maxence", 0DH,0AH
			DB "$"
			
	MESS1 	DB "Veuillez saisir un premier nombre.", 0DH,0AH
			DB "$"
			
	MESSOP 	DB "Veuillez choisir un des 4 opérateurs suivants : (+,-,*,/)", 0DH,0AH
			DB "$"
			
	MESS2 	DB "Veuillez saisir un deuxieme nombre.", 0DH,0AH
			DB "$"
			
	MESSRES DB " : Voici votre resultat ", 0DH,0AH
			DB "$"		
		
			
	CODE ENDS
END DEBUT