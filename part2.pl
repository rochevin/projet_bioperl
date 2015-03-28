#!/usr/bin/perl
use strict;
use warnings;
use utils;
use Bio::SeqFeatureI;
use Bio::PrimarySeq;
use Bio::SeqIO;
use Bio::DB::GenBank;

######################
##### CONSTANTES #####
######################
my $file_accessions_list 	= "accessions_list.txt";
my $file_genes_blacklist 	= "skip_genes.txt";
my $directoryNameOutGenbank	= "genbank";
my $directoryNameOutFasta	= "fasta";
my $file_accessions_table	= "accessions_table.txt";


######################
#####    MAIN    #####
######################
main();


##########################
####  MAIN FUNCTION   ####
##########################
sub main
{	
	my(%list_accessions, $key_accession, $fileNameOutGenbank, $countFastaTreated);
	my($in, $feature, $seq, $gene, %list_genes_blacklist);
	my($organism, $fileNameOutFasta, $seqCDS, $out, $countGenes);
	$file_accessions_list=$ARGV[0] if (scalar(@ARGV)==1);												# Si l'utilisateur a précisé un nom de fichier contenant une liste d'accessions, on l'affecte

	exit unless(-d $directoryNameOutGenbank);																		# On quitte le programme si le dossier courant ne contient pas de dossier nommé "genbank"
	mkdir($directoryNameOutFasta) unless(-d $directoryNameOutFasta);
	
	%list_accessions = getList($file_accessions_list);													# Récupère la liste d'accessions à partir du fichier source
	%list_genes_blacklist = getList($file_genes_blacklist);

	open(FILEOUTPUT, ">".$file_accessions_table) or die ("Error : $!");
	print FILEOUTPUT "# Accessions\tNb genes\tSpecies\n";

	print "Traitement en cours \n";	
	foreach $key_accession (keys %list_accessions)
	{
		($fileNameOutGenbank=$key_accession) =~ s/[^a-zA-Z0-9_]/_/g;											# On affecte le nom de l'accession à la variable $fileNameOut et on remplace les caractères spéciaux par "_" 
		$fileNameOutGenbank .= ".gbk";

		next unless (-f $directoryNameOutGenbank ."/". $fileNameOutGenbank);

		$in = Bio::SeqIO->new(-file => $directoryNameOutGenbank ."/". $fileNameOutGenbank, -format => 'genbank');
		while ($seq = $in->next_seq()) 
		{
			my $organism = $seq->species->node_name;
			($fileNameOutFasta=$organism) =~ s/[^a-zA-Z0-9_]/_/g;
			$fileNameOutFasta .= ".fasta";
			
			#next if (-f $directoryNameOutFasta ."/". $fileNameOutFasta);
			$out = Bio::SeqIO->new(-file => ">".$directoryNameOutFasta."/".$fileNameOutFasta, -format => "Fasta");
			
			for $feature ($seq->get_SeqFeatures) 
			{
				next unless ($feature->primary_tag eq "CDS");
				next unless ($feature->has_tag('gene'));
				for $gene ($feature->get_tag_values('gene')) 
				{
					next if ($gene =~ /orf/i);
					next if (exists $list_genes_blacklist{$gene});
					#print "$gene \n";
					$seqCDS = $feature->spliced_seq();
					$seqCDS->id($gene);
					$seqCDS->description("");
					$out->write_seq($seqCDS);
					$countGenes++;
				}
			}
			$out->close();
			print FILEOUTPUT $key_accession ."\t". $countGenes ."\t". $organism ."\n";
		}
		$in->close();
	}
	close(FILEOUTPUT);
}


