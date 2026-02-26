#!/usr/bin/perl
use strict;
use warnings;
#perl 201223sfs.fastsimcoal2dadi.pl ./unfold/fastsimcoal2/wcs_1200_jointDAFpop1_0.obs nutalli pugetensis

my $in_file = $ARGV[0];
my $sample1 = $ARGV[1];
my $sample2 = $ARGV[2];

my @frq_data;
my $count = -1;
open(FILE1, $in_file) || die "I can't open";
while (my $line = <FILE1>) {
	chomp $line;
	if ($line =~ /^d/) {
		$count++;
		#print "$line\n";
		my @temp1 = split(/\t/, $line);
		#print "$temp1[1]\n";
		my @temp2 = split(/\s/, $temp1[1]);
		for (my $i = 0; $i < @temp2; $i++) {
			$frq_data[$count][$i] = $temp2[$i];
		}
	}
}
close(FILE1);

my $col = @frq_data;
my $max = @frq_data - 1;
print "$col ";
print "$col ";
print "unfolded ";
print "\"$sample1\" ";
print "\"$sample2\"\n";
for (my $i = 0; $i < @frq_data; $i++) {
	for (my $j = 0; $j < @frq_data; $j++) {
		if (($i == $max) && ($j == $max)) {
			print "$frq_data[$j][$i]\n";
		} else {
			print "$frq_data[$j][$i] ";
		}
	}
}
