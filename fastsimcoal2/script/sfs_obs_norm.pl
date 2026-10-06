#!/usr/bin/perl
use strict;
use warnings;

### ---------------------------------------------------------------------------
### Modified by Claude (Anthropic) 
###
### FIX 1  $sum excluded nothing, so the observed SFS was divided by its GRAND
###        total.  In twoJomon_jointDAFpop1_0.obs the corner cell [0,0] alone
###        holds 1,270,484 of 1,719,898 sites (73.9%) and [18,18] a further
###        169,206 (9.8%).  fastsimcoal2 was run with -0, so its expected SFS
###        covers the POLYMORPHIC cells only and sums to 1 over them.  The two
###        spectra were therefore 6.1x apart and every residual came out
###        negative.  $sum now skips the two corners, which are written as 0.
###
### FIX 2  The output is now raw COUNTS, not proportions.  dadi-cli Plot calls
###        dadi.Plotting.plot_2d_comp_Poisson (not _multinom), so it does not fit
###        the scale out, and the Anscombe/Poisson residual is defined for counts
###        only.  On proportions every residual collapses towards zero and the
###        plot looks perfect regardless of fit.
###
### FIX 3  The original zeroed any cell whose frequency did not exceed 1/$sum,
###        i.e. every cell with a count of 1 or less.  Those are real
###        observations, so the cutoff is now 0.  Set $cutoff = 1 to restore the
###        original behaviour.
### ---------------------------------------------------------------------------

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
		my @temp2 = split(/\s+/, $temp1[1]);   ### FIX: \s -> \s+ (runs of blanks gave empty fields)
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

my $nrow = $i + 1;
my $max  = $nrow - 1;
die "$ARGV[0]: $nrow rows but $colnum columns\n" unless $nrow == $colnum;

my $grand = $sum;                                   ### FIX 1
$sum = $grand - $data[0][0] - $data[$max][$max];    ### FIX 1: drop the two corner cells

printf STDERR "%s: %dx%d SFS\n", $ARGV[0], $nrow, $colnum;
printf STDERR "  grand total        %18.1f\n", $grand;
printf STDERR "  cell [0,0]         %18.1f  (%.1f%%)\n", $data[0][0], 100*$data[0][0]/$grand;
printf STDERR "  cell [%d,%d]       %18.1f  (%.1f%%)\n", $max, $max, $data[$max][$max], 100*$data[$max][$max]/$grand;
printf STDERR "  polymorphic total  %18.1f   <-- the expected SFS is rescaled to this\n", $sum;

print "$header1\n";
print "$header2\n";
for (my $k = 0; $k < $i+1; $k++) {
	print "$colname[$k]\t";
	for (my $m = 0; $m < $colnum; $m++) {
		my $freq = $data[$k][$m];                   ### FIX 2: was $data[$k][$m] / $sum
		my $cutoff = 0;                             ### FIX 3: was 1 / $sum
		$freq = 0 if (($k == 0 && $m == 0) || ($k == $max && $m == $max));   ### FIX 1
		if ($freq > $cutoff) {
			if ($m == $colnum-1) { printf ("%.7f\n", $freq); }
			else { printf ("%.7f ", $freq); }
		} else {
			if ($m == $colnum-1) { print "0\n"; }
			else { print "0 "; }
		}
	}
}
