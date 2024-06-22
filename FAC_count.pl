my $fastq_regex = ""; #"FASTQ_Generation_2024-06-08_16_26_26Z-738831189/*/*.fastq";
my $lstkw = ""; #"presort-B,sort-1B,sort-2B,sort-3B,sort-4B";
my $lstkw_label = "NA";
my $subseq_regex = ".*GAATTC([ACGT]{50,65})CTGCAG.*";
my $refs = "NA"; #"ref.fna";
my $out = ""; #"out.fac.txt";

my $ind = 0;
foreach(@ARGV) {

	if (@ARGV[$ind] eq '-fastq_regex') {
		$fastq_regex = @ARGV[$ind + 1];
	}
	
	if (@ARGV[$ind] eq '-keywords') {
		$lstkw = @ARGV[$ind + 1];
	}
	
	if (@ARGV[$ind] eq '-labels') {
		$lstkw_label = @ARGV[$ind + 1];
	}
	
	if (@ARGV[$ind] eq '-subseq_regex') {
		$subseq_regex = @ARGV[$ind + 1];
	}
	
	if (@ARGV[$ind] eq '-out') {
		$out = @ARGV[$ind + 1];
	}
	
	if (@ARGV[$ind] eq '-ref') {
		$refs = @ARGV[$ind + 1];
	}
	
	$ind++;
}

if (length($fastq_regex) == 0 or $fastq_regex eq "NA") {
	print "FASTQ file paths (in regex) is required.\n";
	exit;
}

if (length($out) == 0 or $out eq "NA") {
	print "Output directory path is required.\n";
	exit;
}

my @files = glob("$fastq_regex");

if (scalar(@files) == 0) {
	print "No FASTQ file matches to the pattern $fastq_regex.\n";
	exit;
}

my %seq_to_id = ();
my %seq_to_type = ();

my $count = 0;
my $seqid = "";
my $seqstr = "";
my $seqtype = "";

my %colnames = ();

if (length($lstkw_label) == 0 or $lstkw_label eq "NA") {
	$lstkw_label = $lstkw;
}

if (length($lstkw) > 0 and $lstkw ne "NA") {
	my @toks_lstkw = split(",", $lstkw);
	my @toks_lstkw_label = split(",", $lstkw_label);

	for (my $i = 0; $i < scalar(@toks_lstkw); $i++) {
		my $kw = $toks_lstkw[$i];
	
		if ($i < scalar(@toks_lstkw_label)) {
			$colnames{$kw} = $toks_lstkw_label[$i];
		} else {
			$colnames{$kw} = $kw;
		}
	}
}
$colnames{"zZZZZZ"}="zZZZZZ";

if (-e $refs) {
	open(LOOKUP, $refs);
	while(my $line = <LOOKUP>) {
		chomp $line;
	
		if ($line =~ /^>/) {
			if ($count > 0) {
				$seq_to_id{$seqstr} = $seqid;
				$seq_to_type{$seqstr} = $seqtype;
			
				$seqid = "";
				$seqstr = "";
				$seqtype = "";
			}
		
			($seqid, $seqtype) = ($line =~ /^>(\S+)(.*)/);
			$seqtype =~ s/^\s+//g;
		
			if (length($seqtype) == 0) {
				$seqtype = "NA";
			}
		
			$count++;
		} else {
			$seqstr .= $line;
		}
	}
	close(LOOKUP);

	$seq_to_id{$seqstr} = $seqid;
	$seq_to_type{$seqstr} = $seqtype;

	$seqid = "";
	$seqstr = "";
	$seqtype = "";
}

$count = 0;

my %tally = ();
foreach my $file (@files) {
	if ($file =~ /_R2_/) {
		next;
	}
	
	print "$file\n";
	
	my $bin = "zZZZZZ";
	foreach my $kw (keys(%colnames)) {
		if ($file =~ /$kw/) {
			$bin = $kw;
			last;
		}
	}
	
	if ($bin eq "") {
		next;
	}
	
	open(F, "$file");
	while (my $line = <F>) {
		chomp $line;
		my ($seq) = ($line =~ /$subseq_regex/);
		$count++;
		
		if ($seq eq "") {
			next;
		}
		
		if (not exists $tally{$bin}{$seq}) {
			$tally{$bin}{$seq} = 1;
		} else {
			$tally{$bin}{$seq}++;
		}
		
		if (not -e $refs) {
			$seq_to_id{$seq} = "SEQ_" . $count;
			$seq_to_type{$seq} = "NA";
		}
	}
	close(F);
}

open(RESULT, ">$out");

my $header = "Sequence_ID\tDescription";
foreach my $kw (sort { $a cmp $b } keys(%colnames)) {
	$header .= "\t" . $colnames{$kw};
}
$header .= "\tSequence\n";
$header =~ s/zZZZZZ/all_others/g;
print RESULT $header;

foreach my $seq (keys(%seq_to_id)) {
	my $id = $seq_to_id{$seq};
	my $type = $seq_to_type{$seq};
	
	my $strout = "$id\t$type";
	foreach my $kw (sort { $a cmp $b } keys(%colnames)) {
		my $freq = (exists $tally{$kw}{$seq})? ($tally{$kw}{$seq}):0;
		$strout .= "\t$freq";
	}
	$strout .= "\t$seq\n";
	print RESULT $strout;
}
close(RESULT);
