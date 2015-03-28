# Retourne un tableau associatif contenant la liste d'accessions ou de gènes blacklistés à partir d'un fichier donné
sub getList
{
	my($file_list)=@_;
	my($ligne, %list);

	open(FINPUT, '< '. $file_list) or die("Cannot open $file_list : $! \n");
	while ($ligne = <FINPUT>)
	{
		next if ($ligne =~ /^#/);
		next if ($ligne =~ /^\n/);
		chomp $ligne;
		$list{$ligne}++;
	}
	close(FINPUT);

	return %list;
}

return 1;
