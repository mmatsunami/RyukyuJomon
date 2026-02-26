#!/usr/bin/perl
use strict;
use warnings;

my @data;
my $i = -1;
my $sum = 0;
my $line_count = 0;
my $header1; my $header2;
my @colname;
my $colnum;

open(FILE1, $ARGV[0]) || die "I can't open";
while (my $line = <FILE1>) {
	chomp $line;
	$line_count++;
	if ($line =~ /^d/) {
		$i++;
		my @temp1 = split(/\t/, $line);
		my @temp2 = split(/\s/, $temp1[1]);
		$colnum = @temp2;
		$colname[$i] = $temp1[0];
		for (my $j = 0; $j < @temp2; $j++) {
			$data[$i][$j] = $temp2[$j];
			$sum = $sum + $temp2[$j];
		}
	} elsif ($line_count == 1) {
		$header1 = $line;
	} elsif ($line_count == 2) {
		$header2 = $line;
	}
}
close(FILE1);

#print "$sum\n";
#print "$data[60][60]\n";

print "$header1\n";
print "$header2\n";
for (my $k = 0; $k < $i+1; $k++) {
	print "$colname[$k]\t";
	for (my $m = 0; $m < $colnum; $m++) {
		my $freq = $data[$k][$m] / $sum;
		my $cutoff = 1 / $sum;
		if ($freq > $cutoff) {
			if ($m == $colnum-1) { printf ("%.7f\n", $freq); }
			else { printf ("%.7f ", $freq); }
		} else {
			if ($m == $colnum-1) { print "0\n"; }
			else { print "0 "; }
		}
	}
}

