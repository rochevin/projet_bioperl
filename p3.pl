#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Récupérer des séquences au format fasta contenu dans un dossier 
#afin de compresser les informations dans un seul fichier fasta

use strict;
use extract_data;
use Bio::SeqIO;


print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p3              #\n";
print "#                                                  #\n";
print "####################################################\n";
#On définit nos variables 
my $file_accessions_table = "accessions_table.txt";
my %orga=get_hash_with_file($file_accessions_table,2);
#On définit le fichier de sortie
my $file_out="bank1.fasta";
#On l'ouvre
my $out = Bio::SeqIO->new(-file => ">fasta/".$file_out, -format => "Fasta");

my $compteur=0;
#On parcours la liste des organismes
foreach my $orga (sort { $a cmp $b } keys %orga) {
	#On définit le nom du fichier fasta correspondant à l'organisme
    my $file_in="fasta/".$orga.".fasta";
    next unless (-f $file_in);
    print "Ecriture de ".$file_in." dans ".$file_out;
    #Et on l'ouvre
    my $in = Bio::SeqIO->new(-file => $file_in, -format => 'fasta');
    #On parcours les séquences
    while (my $seq = $in->next_seq()) {
    	#On rajoute juste le nom de l'organisme
        $seq->description($orga);
        #Et on écris dans le nouveau fichier
        $out->write_seq($seq);
        $compteur++;
    }
    $in->close();
    print "... OK !\n";
}
$out->close();
print "Nombre de séquences dans ".$file_out." : ".$compteur."\n";