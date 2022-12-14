IDENTIFICATION DIVISION.
	PROGRAM-ID. Touche-Coule.
	DATE-WRITTEN. 28/10/2022.
	AUTHOR. Hippolyte Damay--Glorieux.
	REMARKS. "Voici un jeu de touché-coulé ou de bataille navale fait en COBOL. Cette version se joue en deux contre deux".
DATA DIVISION.
	WORKING-STORAGE SECTION.
		*>--------------------------------------------------------------
		*>	Tableau de ce que sait le joueur de la flotte de l'ordi 
		*>--------------------------------------------------------------
		01	ZONE_DE_JEU.
			05	ZDJ_LIGNE			OCCURS	10	TIMES.
				10	ZDJ_COLONNE		OCCURS	10	TIMES.
					15 	ZDJ_CELL	PIC X		VALUE	"~".
					15	FILLER		PIC X		VALUE 	SPACE.
		*>--------------------------------------------------------------
		*>	Un tableau commun aux deux joueurs qui représente la flotte
		*>	du joueur
		*>--------------------------------------------------------------
		01	FLOTTE.
			05	FLO_LIGNE			OCCURS	10	TIMES.
				10	FLO_COLONNE		OCCURS	10	TIMES.
					15	FLO_CELL	PIC X		VALUE	"~".
						88	EAU			VALUE	"~".
						88	TOUCHE			VALUE	"@".
						88	RATE			VALUE 	"X".
						88	INTACT			VALUE	"#".
					15	FILLER		PIC X		VALUE	SPACE.
			05	VALIDITE			PIC X(8)	VALUE "VALIDE".
				88	FLOTTE_INVALIDE				VALUE "INVALIDE".
				88	FLOTTE_VALIDE				VALUE "VALIDE".
		*>--------------------------------------------------------------
		*>	Stockage des flottes des deux joueurs
		*>--------------------------------------------------------------
		77	FLO_J1					PIC X(200).
		77	FLO_J2					PIC X(200).
		77	FLO_VIDE				PIC X(200).
		*>--------------------------------------------------------------
		*>	Savoir qui est le joueur
		*>--------------------------------------------------------------
		01	JOUEURS.
			02	NOM_J1				PIC X(20).
			02	NOM_J2				PIC X(20).
			02	JOUEUR_ACTUEL			PIC 9		VALUE 1.
				88	J1			VALUE 1.
				88	J2			VALUE 2.
			02	NOM_JOUEUR_ACTUEL		PIC X(20).
		*>--------------------------------------------------------------
		*>	Gérer l'attaque de la flotte adverse
		*>--------------------------------------------------------------
		01	ASSAUT.
			02	ATQ_X				PIC 99.
			02	ATQ_Y				PIC 99.
			02	CONTINUER_ASSAUT		PIC 9.
				88	CONTINUER				VALUE 1.
				88	ARRET					VALUE 2.
		01	BATEAU.
			02	BATEAU_X			PIC 99.
			02	BATEAU_Y			PIC 99.
			02	ORIENTATION_BAT			PIC X.
				88	VERTICAL				VALUE "V".
				88	HORIZONTAL				VALUE "H".
			02	TAILLE				PIC 9.
		01	NB_TOUCHE				PIC 99.
			88	VICTOIRE					VALUE	17.
		77	IDX					PIC 99.
		77	JDX					PIC 99.
		77	I					PIC 99.
	SCREEN SECTION.
		*> Plage de saisie pour l'attaque
		01	PLS_ATQ.
			02	LINE 16 COL 3 	VALUE "Quelle case voulez vous attaquer ?".
			02	LINE 16 COL 38	PIC XX TO ATQ_X REQUIRED.
			02	LINE 16 COL 41	PIC XX TO ATQ_Y	REQUIRED.
			
		*> Plage de saisie pour initialiser la flotte
		01	PLS_FLO.
			02	LINE 16 COL 3	VALUE	"Ou poser le bateau de taille   ?".
			02	LINE 16 COL 32	PIC 9 FROM TAILLE.
			02	LINE 16 COL 36	PIC 99 TO BATEAU_X REQUIRED BLANK WHEN ZERO.
			02	LINE 16 COL 39	PIC 99 TO BATEAU_Y REQUIRED BLANK WHEN ZERO.
			02	LINE 16	COL 42	PIC X TO ORIENTATION_BAT REQUIRED.
			02	LINE 16	COL 43	VALUE	". Etat de la flotte: ".
			02 	LINE 16 COL 64	PIC X(8) FROM VALIDITE.
		
		01	PLS_NJ1.
			02 BLANK SCREEN.
			02 LINE 16 COL 3	VALUE	"Joueur 1 entrez votre nom".
			02 LINE 16 COL 29	PIC X(20) TO NOM_J1.

		01	PLS_NJ2.
			02 BLANK SCREEN.
			02 LINE 16 COL 3	VALUE	"Joueur 2 entrez votre nom".
			02 LINE 16 COL 29	PIC X(20) TO NOM_J2.
		
		*> Plage d'affichage du joueur en cours
		01	PLA_JOU.
			02	LINE 17	COL 3	VALUE	"Joueur actuel: ".
			02	COL 18		PIC X(11) FROM	NOM_JOUEUR_ACTUEL.
		
		*> Plage d'affichage de la zone de jeu
		01	PLA_ZDJ.
			02	LINE 3 	COL 8	VALUE	"Zone de Jeu".
			02	LINE 4	COL 4	VALUE	"1 2 3 4 5 6 7 8 9 10".
			02	LINE 5	COL 4	PIC X(20) FROM	ZDJ_LIGNE(1).
			02	LINE 6	COL 4	PIC X(20) FROM	ZDJ_LIGNE(2).
			02	LINE 7	COL 4	PIC X(20) FROM	ZDJ_LIGNE(3).
			02	LINE 8	COL 4	PIC X(20) FROM	ZDJ_LIGNE(4).
			02	LINE 9	COL 4	PIC X(20) FROM	ZDJ_LIGNE(5).
			02	LINE 10	COL 4	PIC X(20) FROM	ZDJ_LIGNE(6).
			02	LINE 11	COL 4	PIC X(20) FROM	ZDJ_LIGNE(7).
			02	LINE 12	COL 4	PIC X(20) FROM	ZDJ_LIGNE(8).
			02	LINE 13	COL 4	PIC X(20) FROM	ZDJ_LIGNE(9).
			02	LINE 14	COL 4	PIC X(20) FROM	ZDJ_LIGNE(10).
			
		*> Plage d'affichage de la flotte
		01	PLA_FLO.
			02	LINE 3 	COL 34	VALUE	"Flotte".
			02	LINE 4	COL 26	VALUE	"1 2 3 4 5 6 7 8 9 10".
			02	LINE 5	COL 26	PIC X(20) FROM	FLO_LIGNE(1).
			02	LINE 6	COL 26	PIC X(20) FROM	FLO_LIGNE(2).
			02	LINE 7 	COL 26	PIC X(20) FROM	FLO_LIGNE(3).
			02	LINE 8	COL 26	PIC X(20) FROM	FLO_LIGNE(4).
			02	LINE 9	COL 26	PIC X(20) FROM	FLO_LIGNE(5).
			02	LINE 10	COL 26	PIC X(20) FROM	FLO_LIGNE(6).
			02	LINE 11	COL 26	PIC X(20) FROM	FLO_LIGNE(7).
			02	LINE 12	COL 26	PIC X(20) FROM	FLO_LIGNE(8).
			02	LINE 13	COL 26	PIC X(20) FROM	FLO_LIGNE(9).
			02	LINE 14	COL 26	PIC X(20) FROM	FLO_LIGNE(10).
		
		*> Base de l'écran
		01	PLA_BASE.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 5	COL 2	PIC 9	VALUE	1.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 6	COL 2	PIC 9	VALUE	2.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 7	COL 2	PIC 9	VALUE	3.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 8	COL 2	PIC 9	VALUE	4.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 9	COL 2	PIC 9	VALUE	5.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 10	COL 2	PIC 9	VALUE	6.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 11	COL 2	PIC 9	VALUE	7.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 12	COL 2	PIC 9	VALUE	8.
			02	FILLER	COL 1	PIC X	VALUE 	SPACE.
			02	LINE 13	COL 2	PIC 9	VALUE	9.
			02	LINE 14	COL 1	PIC 99	VALUE	10.
		
		*> Plage d'affichage du titre
		01	PLA_TTL.
			02	BLANK SCREEN.
			02	LINE 1	COL 10	VALUE	"TOUCHE COBOL par HashDG".
		
		*> Plage d'affichage de fin
		01 	PLA_FIN.
			02	LINE 17 		BLANK LINE.
			02	LINE 17	COL 3		VALUE 	"Fin de la partie ! Gagnant: ".
			02	COL 31	PIC X(11)	FROM	NOM_JOUEUR_ACTUEL.
			
PROCEDURE DIVISION.
	PERFORM INITIALISER_FLOTTES.
	SET J1 TO TRUE.
	MOVE NOM_J1 TO NOM_JOUEUR_ACTUEL.
	MOVE FLO_J1 TO FLOTTE.
	DISPLAY PLA_TTL.
	DISPLAY PLA_BASE.
	PERFORM TEST AFTER UNTIL VICTOIRE
		MOVE ZERO TO NB_TOUCHE

		DISPLAY PLA_JOU, PLA_FLO
		
		EVALUATE TRUE *> joueur qui va jouer
			WHEN J1 MOVE FLO_J2 TO FLOTTE
			WHEN J2 MOVE FLO_J1 TO FLOTTE
		END-EVALUATE
		
		MOVE FLOTTE TO ZONE_DE_JEU
		INSPECT ZONE_DE_JEU REPLACING ALL "#" BY "~"
		DISPLAY PLA_ZDJ
		
		SET CONTINUER TO TRUE
		PERFORM TEST BEFORE UNTIL ARRET
			ACCEPT PLS_ATQ
			IF INTACT(ATQ_X, ATQ_Y) OR TOUCHE(ATQ_X, ATQ_Y) THEN
				SET TOUCHE(ATQ_X, ATQ_Y) TO TRUE
			ELSE
				SET RATE(ATQ_X, ATQ_Y) TO TRUE
				SET ARRET TO TRUE
			END-IF
			
			MOVE FLOTTE TO ZONE_DE_JEU
			INSPECT ZONE_DE_JEU REPLACING ALL "#" BY "~"
			DISPLAY	PLA_ZDJ			
		END-PERFORM
		
		INSPECT FLOTTE TALLYING NB_TOUCHE FOR ALL "@"

		IF NOT VICTOIRE THEN
			EVALUATE TRUE
				WHEN J1
					MOVE FLOTTE TO FLO_J2
					SET J2 TO TRUE
					MOVE NOM_J2 TO NOM_JOUEUR_ACTUEL
				WHEN J2
					MOVE FLOTTE TO FLO_J1
					SET J1 TO TRUE
					MOVE NOM_J1 TO NOM_JOUEUR_ACTUEL
			END-EVALUATE
		END-IF
	END-PERFORM.
	DISPLAY PLA_FIN.
	STOP RUN.
	
	INITIALISER_FLOTTES.
		MOVE FLOTTE TO FLO_VIDE.
		ACCEPT PLS_NJ1.
		DISPLAY PLA_TTL.
		PERFORM 2 TIMES
			DISPLAY PLA_FLO
			SET FLOTTE_VALIDE TO TRUE
			
			MOVE 5 TO TAILLE
			ACCEPT PLS_FLO
			PERFORM AJOUTER_BATEAU
			DISPLAY PLA_FLO

			MOVE 4 TO TAILLE
			ACCEPT PLS_FLO
			PERFORM AJOUTER_BATEAU
			DISPLAY PLA_FLO
			
			PERFORM 2 TIMES
				MOVE 3 TO TAILLE
				ACCEPT PLS_FLO
				PERFORM AJOUTER_BATEAU
				DISPLAY PLA_FLO
			END-PERFORM
			
			MOVE 2 TO TAILLE
			ACCEPT PLS_FLO
			PERFORM AJOUTER_BATEAU
			DISPLAY PLA_FLO
			
			IF J1 THEN
				ACCEPT PLS_NJ2
				SET J2 TO TRUE
				MOVE FLOTTE TO FLO_J1
				MOVE FLO_VIDE TO FLOTTE
			ELSE
				SET J1 TO TRUE
				MOVE FLOTTE TO FLO_J2
			END-IF
			DISPLAY PLA_TTL
		END-PERFORM.
		MOVE FLO_J1 TO FLOTTE.

	AJOUTER_BATEAU.		
		MOVE BATEAU_X TO IDX.
		MOVE BATEAU_Y TO JDX.
		
		PERFORM VARYING I FROM 1 BY 1 UNTIL INTACT(IDX, JDX) OR I IS EQUAL TAILLE
			EVALUATE TRUE
				WHEN VERTICAL
					ADD 1 TO IDX
				WHEN HORIZONTAL
					ADD 1 TO JDX
				WHEN OTHER
					SET FLOTTE_INVALIDE TO TRUE
			END-EVALUATE
		END-PERFORM.
		
		IF FLOTTE_VALIDE THEN
			SET INTACT(BATEAU_X, BATEAU_Y) TO TRUE
			SUBTRACT 1 FROM TAILLE
			PERFORM TAILLE TIMES
				EVALUATE TRUE 	
					WHEN VERTICAL
						ADD 1 TO BATEAU_X
					WHEN HORIZONTAL
						ADD 1 TO BATEAU_Y
				END-EVALUATE
				SET INTACT(BATEAU_X, BATEAU_Y) TO TRUE
			END-PERFORM
		END-IF.
