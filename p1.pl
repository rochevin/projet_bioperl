#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Récupérer des fichiers au format genbank pour une liste de numéros d'accession.


use Bio::DB::EUtilities;
use extract_data;
use strict;


print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p1              #\n";
print "#                                                  #\n";
print "####################################################\n";
########Creation repertoire###
#On créer le répertoire genbank uniquement si il n'existe pas
if (! -d "genbank") {
    mkdir ('genbank',0755) || die ("Erreur de création du répertoire \"genbank\" \n");
}

#On définit le fichier à parser
my $file_in ="accessions_list.txt";
#On l'envoit à la fonction d'extraction
my %ids =get_hash_with_file($file_in,0);


#On parcours chaque id du fichier
foreach my $id (keys %ids) {
	#On définit le nom du fichier
    my $file = "genbank/".$id.".gbk";
    #Et on execute la requête uniquement si celui-ci n'existe pas
    if (! -f $file) {
        print "Requête id : ".$id." en cours...\nCréation du fichier ".$file." ... ";
        #On définit une nouvelle requête avec EUtilities
        my $factory = Bio::DB::EUtilities->new(
            -eutil =>'efetch',
            -db => 'nucleotide',
            -id => [ $id ],
            -email => 'vincent.rocher@etu.univ-rouen.fr',
            -rettype => 'gb'
        );
        #On récupère la réponse au format genbank qu'on enregistre dans le fichier
        $factory->get_Response(-file => $file);
        print "OK !\n";
    }
    #Si il existe on print qu'il existe déjà
    else {
        print $id.".gbk existe déjà.\n";
    }
}