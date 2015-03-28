#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Filtrer les résultats d'un blast et ne conserver que les hit supérieur a 300 bp et 95% d'identité
#Enregistrer les résultats dans un fichier csv


use strict;
use Bio::SearchIO;


print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p5              #\n";
print "#                                                  #\n";
print "####################################################\n";

#On définit les fichiers d'entré et de sortie
print "Traitement en cours ...\n";
my $file_in = "XXX_blast_out.txt";
my $file_out="XXX_blast.csv"; 

#On ouvre le fichier d'entré
print "Ouverture du fichier ".$file_in."\n";
my $in = new Bio::SearchIO(-format => 'blast', -file => $file_in); 

#On ouvre le fichier de sortie
unless ( open(file_out, ">".$file_out) ) {
    print STDERR "impossible de trouver $file_out ...\n\n";
    exit;
}
#On commence à écrire dans le fichier de sortie l'en-tête
print file_out "q_name\tq_start\tq_end\th_name\th_start\th_end\tscore\te-value\tlength\tid\tid_pct\n";
#On parcours chaque résultat du fichier
while (my $result = $in->next_result) {
	#On parcours chaque hit
	while (my $hit = $result->next_hit) {
		#On parcours chaque hsp
		while (my $hsp = $hit->next_hsp) {
			#On next si la taille est inferieur à 300bp et 95% d'identité
			next if ($hsp->length('hit') <300);
			next if ($hsp->percent_identity < 95);
			#Et on print les résultats dans le fichier
			print file_out $result->query_name."\t".$hsp->start('query')."\t".$hsp->end('query') 
			."\t".$hit->name."\t".$hsp->start('subject')."\t".$hsp->end('subject')
			."\t".$hsp->score."\t".$hsp->evalue."\t".$hsp->length('hit')
			."\t".$hsp->length('hit')."/".$hsp->length('total')
			."\t".sprintf("%3d", $hsp->percent_identity)
			."\n"; 
		}
	} 
}
#On ferme le fichier
print "Nouveau fichier ".$file_out." généré.\n";
close file_out;