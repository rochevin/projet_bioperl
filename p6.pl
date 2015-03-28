#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Répondre aux questions suivantes :
#-Combien de genes sont communs a toutes les especes (ie presents dans 100 % des 33 especes utilisees)
#
#-Parmi les genes communs aux 33 especes combien sont retrouves dans l'assemblage de l'espece XXX ?
#
#-Parmi les genes trouves dans l'assemblage XXX, lesquels semblent dupliques, tripliques ou plus 
#par rapport a Arabidopsis thaliana ?


use strict;
use extract_data;
use Bio::SeqIO;

print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p6              #\n";
print "#                                                  #\n";
print "####################################################\n";

#On définit les fichiers d'entré
my $file_accessions_summary = "summary.csv";
my $file_accessions_blast = "XXX_blast.csv";
#On envoit a la fonction le nom du fichier et l'endroit ou contient les informations
my %one_hundred_percent=get_hash_with_file($file_accessions_summary,34); #Ne récupère le nom du gene que dans le cas ou il est présent chez toutes les espèces
my %blast_gene_list = get_hash_with_file($file_accessions_blast,3);
#On définit l'espèce d'intérêt
my $specie = "Arabidopsis_thaliana";
my %liste_duplication=();


###Liste gene de XXX####
#On récupère l'information sous la forme gene_espece
#On ne va donc conserver que l'information du nom du gene pour la question 2
#Et on enregistre dans un tableau associatif les gènes correspondant à l'espèce dans le fichier blast pour la question 3
#Pour chaque élément (gene_espece) du tableau ...
foreach my $elmt (keys %blast_gene_list){
	#On extrait le nom du gene
    my ($name) = $elmt =~ /^([^_]+)_/;
    #Si dans gene_espece, espece = $specie (Arabidopsis_thaliana)
    if ($elmt =~ /$specie/i ) {
    	#On enregistre la valeur (cad le nombre de fois ou le gene est présent dans le cas ou espece = $specie)
    	#dans le nouveau tableau associatif avec juste le nom du gene pour répondre à la question 3
		$liste_duplication{$name}=$blast_gene_list{$elmt};
	}
	#Dans tous les cas on suprimme l'ancienne information
	delete( $blast_gene_list{$elmt} );
	#Et on reformate l'info sous la forme nom du gene uniquement
	#Rq : On suprimme de l'information initiale cad si le gene est dupliqué chez une même espèce mais n'empeche pas de répondre
	#A la question 2
    $blast_gene_list{$name}++;
}

#Le fichier de sortie est ouvert en écriture
my $file_out="part6_out.txt"; 
unless ( open(file_out, ">".$file_out) ) {
    print STDERR "Impossible de trouver $file_out ...\n\n";
    exit;
}


###QUESTION 1###
###Nombre de gene present chez toutes les espèces###
my @full_liste_XXX = keys %one_hundred_percent; #On enregistre les clés dans une liste
#Et on print le résultat
print file_out "Question 1 :\n".scalar @full_liste_XXX." genes communs aux 33 espèces (".join(' ',@full_liste_XXX).")\n\n";
print "Question 1 OK !\n";
###QUESTION 2###
###Parmis les genes present chez toutes les espèces, combien sont retrouvés chez XXX ?###
my @liste_100_XXX;
#On parcours la liste des genes présent chez toutes les espèces ...
foreach my $elmt (%one_hundred_percent){
	#Et on l'enregistre dans la liste seulement si il est présent dans le fichier XXX
    if (exists $blast_gene_list{$elmt}) {
        push @liste_100_XXX,$elmt;
    }
}
#Et on print le résultat
print file_out "Question 2 :\n".scalar @liste_100_XXX." genes communs aux 33 espèces (".join(' ',@liste_100_XXX).")\n\n";
print "Question 2 OK !\n";
###QUESTION 3###
###Gene de XXX dupliqué, tripliqué ou plus###
print file_out "Question 3 : genes présents dans XXX avec plusieurs copies par rapport à ".$specie."\n";
#On va créer un tableau associatif qui va inverser les clés et les valeurs tout en évitant d'écraser les valeurs lors de redondance, grâce à une liste 
my %inversion_table;
#On push chaque clé dans une liste qui devient la valeur de l'ancienne valeur
#Ex : nad4 => 4 devient 4 => [nad4]
push @{ $inversion_table{ $liste_duplication{$_} }}, $_ for keys %liste_duplication;
#Ensuite on parcours ce nouveau tableau et on print le résultat...
foreach my $elmt (sort { $a <=> $b } keys %inversion_table){
	next if ($elmt < 2); #On ne veut que les gènes dupliqués ou plus
	#On récupère le nombre d'éléments dans la liste
	my $nombre = scalar @{$inversion_table{$elmt}};
	#On print dans le format demandé
	print file_out $nombre." genes avec ".$elmt." copies : ".join(" ", @{$inversion_table{$elmt}})."\n";
}
print "Question 3 OK !\n";
print $file_out." généré.\n";
close file_out;