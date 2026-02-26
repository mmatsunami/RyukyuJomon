#!/usr/bin/perl
use strict;
use warnings;

my %cent_data; #key => seqnames, value => chr, start, end
open(FILE1, $ARGV[0]) || die "I can't open";
while (my $line = <FILE1>) {
	chomp $line;
	unless ($line =~ /^seqnames/) {
		my @temp = split(/\t/, $line);
		$temp[1] =~ s/chr//g;
		$cent_data{$temp[0]} = {
			chr   => $temp[1],
			start => $temp[2],
			end   => $temp[3],
		};
	}
}
close(FILE1);

#for (my $i = 1; $i < scalar(keys %cent_data)+1; $i++) {
#	print "$i\t";
#	print "$cent_data{$i}{chr}\t";
#	print "$cent_data{$i}{start}\t";
#	print "$cent_data{$i}{end}\n";
#
#}

open(FILE2, $ARGV[1]) || die "I can't open";
while (my $line = <FILE2>) {
	chomp $line;
	unless ($line =~ /^#/) {
		my $flag = 0;
		my @temp = split(/\t/, $line);
		my $chr   = $temp[0];
		my $start = $temp[1];
		my $end   = $temp[2];
		for (my $i = 1; $i < scalar(keys %cent_data)+1; $i++) {
			if ($cent_data{$i}{chr} == $chr) {
				if (&ShowOverlap($cent_data{$i}{start}, $start, $cent_data{$i}{end}, $end)) {
					#print "$chr\t";
					#print "$start\t";
					#print "$end\t";
					#print "$cent_data{$i}{chr}\t";
					#print "$cent_data{$i}{start}\t";
					#print "$cent_data{$i}{end}\n";
					$flag = 1;
				}
			}
		}
		#print "$chr\t";
		#print "$start\t";
		#print "$end\t";
		#print "$flag\n";
		if ($flag == 0) { print "$line\n"; }
	} else {
		print "$line\n";
	}
}
close(FILE2);



sub ShowOverlap {
	my $StartA = $_[0]; my $StartB = $_[1]; my $EndA = $_[2]; my $EndB = $_[3];
	if ((($StartA >= $StartB) && ($StartA <= $EndB) && ($EndA >= $EndB))
	||  (($StartA <= $StartB) && ($StartA <= $EndB) && ($EndA >= $EndB))
	||  (($StartA <= $StartB) && ($StartB <= $EndA) && ($EndA <= $EndB))
	||  (($StartA == $StartB) && ($EndA == $EndB))
	||  (($StartA >= $StartB) && ($EndA <= $EndB))) {
		return 1;
	} else {
		return 0;
	}
}

