#! /usr/bin/perl -w
#Auteur du script : Vincent ROCHER
#But du script : Récupérer sous la forme d'un hash les informations d'une colonne précise dans un fichier
#Fonctionne pour lesp rogrammes p1,p2,p3,p4,p6


sub get_hash_with_file {
    my($file_list,$colonne)=@_;

    unless ( open(file_list, $file_list) ) {
            print STDERR "Impossible de trouver $file_list ...\n\n";
            exit;
        }

    my %list=();
    if ($colonne == 34) {
        foreach my$line (<file_list>) {
            if ( $line =~ /^\s*$/ ){
                next;
            }

            elsif ( $line =~ /^#/ ) {
                next;
            }
            else {  
                chomp $line;
                my @line_content = split("\t", $line);
                if ($line_content[$colonne] eq "100.00") {
                    $list{$line_content[0]}++;
                }
            }   
        }
    }
    else {
        foreach my$line (<file_list>) {
            if ( $line =~ /^\s*$/ ){
                next;
            }

            elsif ( $line =~ /^#/ ) {
                next;
            }
            else {  
                chomp $line;
                my @line_content = split("\t", $line);
                $list{$line_content[$colonne]}++;
            }   
        }
    }
    close file_list;
    return %list;
}
return 1;