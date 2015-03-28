#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Génerer un fichier csv contenant la présence ou l'absence des genes chez les espèces d'intérêt 
#et si présence d'indiquer leur taille

use strict;
use Bio::SeqIO;
use extract_data;

print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p4              #\n";
print "#                                                  #\n";
print "####################################################\n";

#On définit le nom du fichier, o nextrait les informations -> organismes
my $file_accessions_table = "accessions_table.txt";
my %orga=get_hash_with_file($file_accessions_table,2);

#On définit un tableau qui contiendras toutes nos informations
my %content = ();
#On calcule le nombre d'organisme pour le pourcentage
my $nbr_orga = keys (%orga);


#Le fichier de sortie est ouvert en écriture
my $file_out="summary.csv"; 
unless ( open(file_out, ">".$file_out) ) {
    print STDERR "Impossible de trouver $file_out ...\n\n";
    exit;
}

#On commence à écrire en format csv
print file_out "\t";
#On parcours chaque organisme
foreach my $organism (sort { $a cmp $b } keys %orga) {
	#On définit le fichier fasta correspondant
	my $file_in="fasta/".$organism.".fasta";
	#Si le fichier n'existe pas on next
	next unless (-f $file_in);
	print "Ouverture du fichier ".$file_in." ...";
	#On l'ouvre
	my $in = Bio::SeqIO->new(-file => $file_in, -format => "Fasta");
	#On parcours les séquences
	while (my $seq = $in->next_seq()) {
	    my $gene_name=$seq->id();
	    my $length = $seq->length;
	    #On enregistre le nom du gene et sa taille dans l'organisme
	    $content{$gene_name}{$organism}=$length;
	}
	$in->close();
	print " OK !\n";
	print file_out $organism."\t";
}
print file_out "% of species where gene is present\n";


#On parcours notre tableau de donnée
foreach my $elmt (sort { $a cmp $b } keys %content) {
	#On commence à écrire dans le fichier csv les informations du gène
	print file_out $elmt."\t";
	my $nbr_gene = 0;
	#On parcours la deuxième dimension du tableau mais avec toute la liste des organimes
	foreach my $sub_elmt (sort { $a cmp $b } keys %orga) {	
		#Si le gene existe chez l'organisme, on print sa taille
		if (exists $content{$elmt}{$sub_elmt}) {
			print file_out $content{$elmt}{$sub_elmt}."\t";
			$nbr_gene++;
		}
		#Sinon on print 0
		else {
			print file_out "0\t";
		}
	}
	#On écris le pourcentage
	printf file_out ("%.2f",($nbr_gene/$nbr_orga)*100);
	print file_out "\n";
}
print $file_out." généré.\n";
close file_out;