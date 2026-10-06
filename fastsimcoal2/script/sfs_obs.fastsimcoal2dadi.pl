#!/usr/bin/perl
use strict;
use warnings;

### ---------------------------------------------------------------------------
### Modified by Claude (Anthropic)
###
### FIX 1  Values are split on any run of whitespace across the whole line rather
###        than on $temp1[1] alone, and the row and column counts are checked.
###        The script now dies instead of silently emitting a short line.
###
### FIX 2  A dadi mask line is appended, masking the corner cells [0,0] and
###        [n,n].  fastsimcoal2 was run with -0 and ignores monomorphic sites, so
###        these cells must be excluded on both sides of the comparison.
### ---------------------------------------------------------------------------

my $in_file = $ARGV[0];
my $sample1 = $ARGV[1];
my $sample2 = $ARGV[2];
die "usage: $0 <obs file> <pop1> <pop2>\n" unless defined $sample2;

my @frq_data;
my $count = -1;
open(FILE1, $in_file) || die "I can't open";
while (my $line = <FILE1>) {
	chomp $line;
	if ($line =~ /^d/) {
		$count++;
		my @temp2 = split(/\s+/, $line);       ### FIX 1: split the whole line
		shift @temp2;                          ### FIX 1: drop the row label
		for (my $i = 0; $i < @temp2; $i++) {
			$frq_data[$count][$i] = $temp2[$i];
		}
	}
}
close(FILE1);

my $col = @frq_data;
my $max = @frq_data - 1;

for (my $r = 0; $r <= $max; $r++) {            ### FIX 1: refuse to write a ragged SFS
	my $got = scalar @{$frq_data[$r]};
	die "$in_file: row $r yielded $got values, expected $col\n" unless $got == $col;
}
printf STDERR "%s: %dx%d SFS, all rows complete\n", $in_file, $col, $col;

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

for (my $i = 0; $i <= $max; $i++) {            ### FIX 2: dadi mask line
	for (my $j = 0; $j <= $max; $j++) {
		my $m = (($i == 0 && $j == 0) || ($i == $max && $j == $max)) ? 1 : 0;
		if (($i == $max) && ($j == $max)) { print "$m\n"; }
		else { print "$m "; }
	}
}
