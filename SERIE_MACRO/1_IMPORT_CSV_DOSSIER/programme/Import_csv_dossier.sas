
options nosource nonotes; /* Optionnel Cacher les autres messages */

%macro drive(dir,ext);
	%put ---------------;
	%put Lancement Macro;
	%put Dossier: &dir.;
	%put Extension: &ext; ;
	%put ---------------;
	/* Déclaration Macro locale */
	%local cnt filrf rc did memcnt name;
	%let cnt=0;
	%let filrf=mydir;

	/* Affichage du message système dans le cas ou l'on arrive pas à assigner le dossier */
	%let rc=%sysfunc(filename(filrf,&dir));
	%if &rc ne 0 %then %put %sysfunc(sysmsg());

	/* Ouverture du dossier */
	%let did=%sysfunc(dopen(&filrf));

	/* Si on peut ouvrir le dossier on continue */
	%if &did ne 0 %then %do;
	/* On compte le nombre de fichiers à importer */
			%let memcnt=%sysfunc(dnum(&did));
			%put --- &memcnt. Fichiers dans le dossier ---;

		/* On boucle sur le Nb de fichiers */
			%do i=1 %to &memcnt;
			%put ---------------;

				/* On assigne les macros nom et ext pour le fichier lu */
				%let file_ext =%qscan(%qsysfunc(dread(&did,&i)),-1,.);
				%let file_name = %qsysfunc(dread(&did,&i));
				%put Fichier &i. : &file_name ; 

				/* On vérifie que le fichier à bien une extension */
				%if %qupcase(%qsysfunc(dread(&did,&i))) ne %qupcase(&file_ext) %then 
				%do;
						/* On vérifie que l'extension match bien avec celle 
							que l'on veut importer*/
						%if %superq(ext) = %superq(file_ext) %then %do;
								/* On lance l'import */
								/* On incrémente de 1 le compteur  */
								%let cnt=%eval(&cnt+1); 
								%put "Import &file_name.";

								/* PROC IMPORT DU FICHIER */
								proc import datafile="&dir\%qsysfunc(dread(&did,&i))" 
									out=dsn&cnt
									dbms=csv replace;
									delimiter=';';
									getnames=yes;
								run;

						%end;
						%else %do; 
						%put "L'extension du fichier ne correspond pas à &ext";
						%end;
				%end; 
				%else %do; 
				%put "Le fichier &file_name. n'a pas d'extension";
				%end;
			%end; /* fin de la boucle */


	%end; 
		
	/* On poste un message d'erreur si on ne peut pas ouvrir le dossier */
	%else %put Erreur le dossier &dir ne peut pas être ouvert.;

	/* Fermeture du dossier */
	%let rc=%sysfunc(dclose(&did));
	%put ---------------;
	%put Fin Macro;
	%put ---------------;
%mend drive;

%drive(C:\Users\GM\Desktop\MACROSERIE\IMPORTCSV\CSV_FOLDER,csv);