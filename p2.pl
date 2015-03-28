#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Extraire les séquences codantes des gènes d'un fichier genbank et les enregistrer au format fasta
#et générer un fichier compte rendu contenant le numero d'accession, le nombre de genes et l'espèce

use strict;
use Bio::SeqIO;
use extract_data;

print "####################################################\n";
print "#                                                  #\n";
print "#           Lancement du programme p2              #\n";
print "#                                                  #\n";
print "####################################################\n";
########Creation repertoire###
#On créer le répertoire fasta uniquement si il n'existe pas
if (! -d "fasta") {
    mkdir ('fasta',0755) || die ("Erreur de création du répertoire \"fasta\" \n");
}


###OUVERTURE FICHIER ######
my $file_accession_input="accessions_list.txt"; #Nom du fichier contenant les infos
my $file_accession_output="accessions_table.txt"; #Nom du fichier qui contiendra les données de sortie du script
my %ids = get_hash_with_file($file_accession_input,0); #On récupère les ids uniquement
my $file_blacklist="skip_genes.txt"; #Nom du fichier qui contient les gènes à exclure
my %gene_blacklist = get_hash_with_file($file_blacklist,0); #On extrait les noms du fichier

#On définit un compteur du nombre de gènes
my $nombre_genes=0;

#On ouvre le fichier file_accession_output (ici accessions_table.txt)
unless ( open(file_output, ">".$file_accession_output) ) {
    print STDERR "Impossible de trouver $file_accession_output ...\n\n";
    exit;
}
#On écrit l'en-tête
print file_output "# Accessions\tNb genes\tSpecie\n";
#On parcours nos ids NC
foreach my $id (sort {substr($a, 3, 6) <=> substr($b, 3, 6)} keys %ids) {
    $nombre_genes=0; #On remet le compteur du nombre de genes à zero
    #On définit le nom du fichier genbank
    my $file_in="genbank/".$id.".gbk";
    #Si il n'existe pas on next
    next unless (-f $file_in);
    print "Ouverture du fichier ".$file_in."\n";
    #On l'ouvre
    my $in = Bio::SeqIO->new(-file => $file_in, -format => 'genbank');
    #On parcours chaque élément à l'intérieur
    while (my $seq = $in->next_seq()) {
    	#On enregistre le nom de l'organisme et on formate son nom pour le nom de fichier
        my $organism = $seq->species->node_name;
        $organism =~ s/\.//g;
        $organism =~ s/[^A-Za-z0-9_]/_/g;
        #On définit un fichier de sortie à partir du nom de l'organisme
        my $file_out=">fasta/".$organism.".fasta";
        #On ouvre le fichier
        my $out = Bio::SeqIO->new(-file => $file_out, -format => "Fasta");
        print "Ecriture dans ".$file_out." ...";
        foreach my $feature ($seq->get_SeqFeatures) {
        	#Pour chaque features, on next sauf si c'est un CDS et qu'il contient le tag gene
            next unless ($feature->primary_tag eq "CDS");
            next unless ($feature->has_tag("gene"));
            #On parcours chaque tag gene de la Feature
            foreach my $tag_gene ($feature->get_tag_values("gene")){     
            	#On next si le nom contient orf et si le nom du gène est contenu dans la blacklist                
                next if ($tag_gene =~ /orf/i);
                next if (exists $gene_blacklist{$tag_gene});
                my $fasta_seq = $feature->spliced_seq();
                #On remplace le nom de la séquence fasta par le nom du gène
                $fasta_seq->id($tag_gene); 
                $fasta_seq->description("");
                #On ecrit dans le fichier la séquence au format fasta
                $out->write_seq($fasta_seq);
                $nombre_genes++;
            }
        }
        $out->close();
        print " OK ! \n\n";
        #On écrit dans notre fichier compte rendu l'id, le nombre de gènes et l'organisme
        print file_output $id ."\t". $nombre_genes ."\t". $organism ."\n";

    }
    $in->close();
}
close file_output;




