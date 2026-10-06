#!/usr/bin/perl
use strict;
use warnings;

### ---------------------------------------------------------------------------
### Modified by Claude (Anthropic) 
###
### FIX 1  THE ROW AND COLUMN COUNTS ARE VALIDATED, and the script dies instead
###        of emitting a short line.
###        Background: fastsimcoal2 writes this file with a fixed field width and
###        drops the separator when a value overflows it.  In the version of
###        twoJomon_jointDAFpop1_0.txt committed before 2026-10-06, 14 of the 19
###        rows carried two values fused into a single token at column 13, e.g.
###            9.68981e-053.57232e-05   =  9.68981e-05  and  3.57232e-05
###            0.0002037577.34886e-05   =  0.000203757  and  7.34886e-05
###        Splitting on tab then produced 18 values instead of 19, every value
###        after the fused token shifted one column left, perl emitted 14
###        "uninitialized value" warnings, the fused strings were written to the
###        output verbatim, and the file carried 347 tokens where dadi expects
###        361.  That file has since been corrected, so no repair is attempted
###        here; this check exists so that the same fault cannot pass silently if
###        fastsimcoal2 is re-run (for example for the bootstrap replicates).
###
### FIX 2  The expected SFS is RESCALED to the observed polymorphic total, given
###        as a 4th argument (a number, or the matching .obs file).  dadi-cli
###        Plot calls dadi.Plotting.plot_2d_comp_Poisson, not _multinom, so it
###        does not fit the scale out: model and data must be supplied on the
###        same scale.  fastsimcoal2 was run with -0, so this file holds
###        proportions of POLYMORPHIC sites summing to 1 with the corners set to
###        0, whereas the observed SFS is in counts over all cells.
###
### FIX 3  A dadi mask line is appended, masking the same two corner cells as the
###        observed SFS.
### ---------------------------------------------------------------------------

my $in_file = $ARGV[0];
my $sample1 = $ARGV[1];
my $sample2 = $ARGV[2];
my $scale   = $ARGV[3];                        ### FIX 2
die "usage: $0 <exp .txt> <pop1> <pop2> <obs .obs file | number of sites>\n"
	unless defined $scale;

my $NUM = qr/^(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?$/;   ### FIX 1

my @frq_data;
my $count = -1;
open(FILE1, $in_file) || die "I can't open";
while (my $line = <FILE1>) {
	chomp $line;
	if ($line =~ /^d/) {
		$count++;
		my @temp1 = split(/\s+/, $line);       ### FIX 1: was split(/\t/, $line)
		shift @temp1;                          ### FIX 1: drop the row label
		for (my $i = 0; $i < @temp1; $i++) {
			die "$in_file: row $count column $i holds '$temp1[$i]', which is not a number.\n"
			  . "  fastsimcoal2 has written two values without a separator.  Re-export the\n"
			  . "  file, or split that field by hand, before running this script.\n"
				unless $temp1[$i] =~ $NUM;     ### FIX 1
			$frq_data[$count][$i] = $temp1[$i];
		}
	}
}
close(FILE1);

my $col = @frq_data;
my $max = @frq_data - 1;

for (my $r = 0; $r <= $max; $r++) {            ### FIX 1
	my $got = scalar @{$frq_data[$r]};
	die "$in_file: row $r yielded $got values, expected $col.\n"
	  . "  The file is malformed -- see the note on fused fields at the top of this script.\n"
		unless $got == $col;
}

### FIX 2: work out the target total, then the rescaling factor
my $target;
if ($scale =~ /^[\d.]+(?:[eE][-+]?\d+)?$/) {
	$target = $scale;
} else {
	my @obs;
	open(FILE2, $scale) || die "I can't open $scale";
	while (my $l = <FILE2>) {
		chomp $l;
		next unless $l =~ /^d/;
		my @g = split(/\s+/, $l);
		shift @g;
		push @obs, \@g;
	}
	close(FILE2);
	die "$scale: expected $col rows, got " . scalar(@obs) . "\n" unless @obs == $col;
	$target = 0;
	for (my $i = 0; $i <= $max; $i++) {
		for (my $j = 0; $j <= $max; $j++) {
			next if ($i == 0 && $j == 0) || ($i == $max && $j == $max);
			$target += $obs[$i][$j];
		}
	}
}

my $sum = 0;
for (my $i = 0; $i <= $max; $i++) {
	for (my $j = 0; $j <= $max; $j++) {
		next if ($i == 0 && $j == 0) || ($i == $max && $j == $max);
		$sum += $frq_data[$i][$j];
	}
}
die "expected SFS sums to zero over the polymorphic cells\n" unless $sum > 0;
my $factor = $target / $sum;

printf STDERR "%s: %dx%d SFS, all rows complete\n", $in_file, $col, $col;
printf STDERR "  expected total over polymorphic cells %14.6f\n", $sum;
printf STDERR "  rescaled to                           %14.1f  (factor %.6g)\n", $target, $factor;

print "$col ";
print "$col ";
print "unfolded ";
print "\"$sample1\" ";
print "\"$sample2\"\n";
for (my $i = 0; $i < @frq_data; $i++) {
	for (my $j = 0; $j < @frq_data; $j++) {
		my $v = $frq_data[$j][$i] * $factor;                               ### FIX 2
		$v = 0 if (($i == 0 && $j == 0) || ($i == $max && $j == $max));     ### FIX 3
		if (($i == $max) && ($j == $max)) { printf ("%.6f\n", $v); }
		else { printf ("%.6f ", $v); }
	}
}

for (my $i = 0; $i <= $max; $i++) {            ### FIX 3: dadi mask line
	for (my $j = 0; $j <= $max; $j++) {
		my $m = (($i == 0 && $j == 0) || ($i == $max && $j == $max)) ? 1 : 0;
		if (($i == $max) && ($j == $max)) { print "$m\n"; }
		else { print "$m "; }
	}
}
