#!/usr/bin/perl -w 
use strict;
use Getopt::Long;
use File::Basename;
use Bio::Seq;
use Bio::SeqIO;

my $mincov = 5;
my $minsupp = 80;
my ($consensus_start, $consensus_end);
my $reference;
my $haplogrep;
my $bqfilter = 0;
my $help;
my $mask = 0;
my $mixed;
my $annotation;

GetOptions ("reference=s" =>\$reference,
	    "support=s" => \$minsupp,
            "coverage=i" => \$mincov,
	    "basequal=i" => \$bqfilter,
	    "haplogrep" => \$haplogrep,
	    "mask=i" => \$mask,
	    "mixed" => \$mixed,
	    "annotation=s" => \$annotation,
            "help" => \$help);
my $infile = $ARGV[0];
&help if $help;
&help unless $infile && $reference;
die "minimum consensus support needs to be >50%\n" unless $minsupp > 50;

my (%anno, %anno_code);
my $code = 115;
if ($annotation) {
    open ANNO, $annotation or die "could not open annotation file: $!\n";
    my $string;
    while (my $line = <ANNO>) {
	chomp $line;
	$string .= $line;
    }
    while ($string =~ s/\[gene=([^\]]+)\] \[location=[complent]*\(?(\d+)\.\.(\d+)\)?\]//) {
	my ($gene, $start, $end) = ($1, $2, $3);
#	print "$gene $start $end\n";###debug
	foreach my $pos ($start .. $end) {
	    $anno{$pos} = $gene;
	    $anno_code{$pos} = $code;
	}
	if ($code == 115) {$code = 118;} else {$code = 115;}
    }
}
#die; ###debug

print STDERR "[consensus_from_bam] reading bam file\n";
open READ, "samtools-0.1.18 view -X -F u $infile |" or die "could not open bam file\n";
my ($interval, %data, %insertion, $haplo);
SEQ:while (my $line = <READ>) {
    chomp $line;
    my $reverse = 0;
    my ($header, $flag, $chromosome, $start, $mapq, $cigar, $junk1, $junk2, $junk3, $sequence, $bq, @others) = split /\t/, $line;
    $reverse = "1" if $flag =~ /r/;
    my $seqlength = length($sequence);
    $interval++; if ($interval == 1_000) {print STDERR "\rcurrent position: $start\t\t"; $interval = 0;}
    my $md;
    foreach my $element (@others) {
	if ($element =~ /MD:[ZA]:(\S+)$/) {
	    $md = $1;
	}
    }
    die "no MD field seen in\n $line\n" unless $md;
    my $genomic_position = $start -1; # because I add 1 per position in the loop
    my ($dist_from_start, $dist_from_end) = (0, length($sequence) + 1); # same here
    CIGAR:while ($cigar =~ s/^(\d+)([MIDS])//) {
	my ($number, $type) = ($1, $2);
	next if $number == 0;
	if ($type eq "S") {
	   CLIP:foreach (1..$number) {
	       $dist_from_start++; $dist_from_end--;
	       $sequence =~ s/^.//;
	       $bq =~ s/^.//;
	   }
	} elsif ($type eq "M") {
	   POS:foreach (1..$number) {
	       $genomic_position++; $dist_from_start++; $dist_from_end--;
	       $sequence =~ s/^(.)// or die "parsing error in cigar field\n";
	       my $base = $1;
	       $bq =~ s/^(.)// or die "parsing error in cigar field/BQ\n";
	       my $basequal = ord($1) -33;
	       next POS if $base eq "N";
	       next POS if $basequal < $bqfilter;
	       if ($mask) {
		   if ($reverse == 0 && $base eq "T") {
		       next POS if $dist_from_start <= $mask;
		       if ($dist_from_end <= $mask) {
			   next POS unless $flag =~ /p/
		       }
		   } elsif ($reverse == 1 && $base eq "A") {
		       if ($dist_from_start <= $mask) {
			   next POS unless $flag =~ /p/;
		       }
		       next POS if $dist_from_end <= $mask;
		   }
	       }
	       $data{$genomic_position}{$base}++;
	       unless ($dist_from_end == 1) {
		   $insertion{"$genomic_position"}++;
	       }
	   }
	} elsif ($type eq "I") { 
	    foreach (1..$number) {
		$insertion{"$genomic_position.$_"}++;
	    }
	    INS:foreach (1..$number) {
		$dist_from_start++; $dist_from_end--;
		$sequence =~ s/^(.)// or die "parsing error2 in cigar field\n";
		my $base = $1;
		$bq =~ s/^(.)// or die "parsing error in cigar field/BQ\n";
		my $basequal = ord($1) -33;
		next INS if $base eq "N";
		next INS if $basequal < $bqfilter;
		if ($mask) {
		    if ($reverse == 0 && $base eq "T") {
			next INS if $dist_from_start <= $mask;
			next INS if $dist_from_end <= $mask;
		    } elsif ($reverse == 1 && $base eq "A") {
			next INS if $dist_from_start <= $mask;
			next INS if $dist_from_end <= $mask;
		    }
		}
		$data{"$genomic_position.$_"}{$base}++;
	    }
	} elsif ($type eq "D") {
	    foreach (1..$number) {
		$genomic_position++;
		$data{$genomic_position}{"-"}++;
	    }
        }
    }
    die "problem in cigar parsing: l$seqlength, $dist_from_start, $dist_from_end\n" unless $dist_from_start == $seqlength && $dist_from_end == 1;
}

my $read_seq = Bio::SeqIO->new(-file => "$reference",
                               -format => "fasta");
my $seq_in = $read_seq->next_seq;
my $sequence = $seq_in->seq;
my $ref_header = $seq_in->id;
my %reference;
my $reflength = length($sequence);
foreach my $position (1.. $reflength) {
    $sequence =~ s/^(.)//;
    $reference{$position} = $1;
}

my $outname = basename($infile);
$outname =~ s/\.bam// or die "input file is not in bam format\n";
my $parameters = "cov${mincov}support${minsupp}basequal${bqfilter}mask$mask";

open DATA, ">$outname.consensus_data.$parameters.tab" or die "could not write consensus_data\n";   
print DATA "#position\trefbase\tinsertion_cov\tobservations\n";
foreach my $position (sort {$a <=> $b} keys %data) {
    print DATA "$position\t", $reference{$position} || "-", "\t";
    print DATA $insertion{$position} || "";
    foreach my $base (keys %{$data{$position}}) {
	print DATA "\t", $data{$position}{$base}, $base;
    }
    print DATA "\n";
}

my %stats;
open SUPP, ">$outname.consensus_support.$parameters.txt" or die "could not write consensus_support\n";
open FAILED, ">$outname.failed_calls.$parameters.txt" or die "could not write failed calls file\n";
my ($consensus_pure, $consensus_aligned, $reference_aligned, $consensus_mixed);
my $max_coverage = 0;
print SUPP join ("\t", "#ref_position", "ref_base", "consensus_base", "coverage", "consensus_support", "low_coverage", "low_cons_support", "annotation", "anno_code");
print FAILED join ("\t", "#ref_position", "ref_base", "consensus_base", "coverage", "consensus_support", "low_coverage", "low_cons_support", "annotation", "anno_code");
print SUPP "\t#parameters:$parameters\n";
print FAILED "\t#parameters:$parameters\n";
foreach my $position (1  .. $reflength) {
    my ($outline, $failed);
    my $refbase = $reference{$position};
    my $uncovered = "";
    $outline .= "$position\t";
    $outline .= "$refbase\t";
    my ($consensus_base, $consensus_support, $coverage) = &consensus($position);
    if ($coverage < $mincov) {
	$consensus_support = $uncovered if $coverage < $mincov;
	$uncovered = 105;
	$failed = "cov";
	$stats{"cov"}++;
    }
    $consensus_support = sprintf ("%.2f", $consensus_support) if $consensus_support;
    $max_coverage = $coverage if $coverage > $max_coverage;
    $outline .= join ("\t", $consensus_base, $coverage, $consensus_support, $uncovered);
    if ($consensus_base =~ /N/ && ! $uncovered) {
	$outline .= "\t110";
	$failed = "supp";
	$stats{"supp"}++;
    } else {
	$outline .= "\t";
    }
    if (exists $anno{$position}) {
	$outline .= "\t". $anno{$position}. "\t". $anno_code{$position};
	if ($failed) {
	    $stats{"anno_supp"}++ if $failed eq "supp";
	    $stats{"anno_cov"}++ if $failed eq "cov";
	}
    } else {
	$outline .= "\t\t";
    }
    $outline .= "\n";
    print SUPP $outline;
    print FAILED $outline if $failed;
    $reference_aligned .= $refbase;
    my $gaps_to_insert = length ($consensus_base) - 1;
    $reference_aligned .= "-" x $gaps_to_insert;
    $consensus_aligned .= $consensus_base;
    $consensus_pure .= $consensus_base;
    if ($consensus_base eq "N") {
	$consensus_mixed .= $refbase;
    } else {
	$consensus_mixed .= $consensus_base;
    }
    if (length($consensus_base) == 1 && $consensus_base =~ /[ACGT]/ && $refbase ne "N" && $consensus_base ne $refbase) {
	$haplo .= "\t$position$consensus_base";
    }
}

my $write_seq = Bio::SeqIO->new(-file   => ">$outname.consensus.$parameters.fas",
                                -format => "fasta");
my $seq = Bio::Seq->new( -seq => $consensus_pure,
                         -id  => "$outname.$parameters");
$write_seq->write_seq($seq);
$write_seq = Bio::SeqIO->new(-file   => ">$outname.consensus_aligned.$parameters.fas",
                             -format => "fasta");
$seq = Bio::Seq->new( -seq => $reference_aligned,
                      -id  => "$ref_header");
$write_seq->write_seq($seq);
$seq = Bio::Seq->new( -seq => $consensus_aligned,
                      -id  => "$outname.$parameters");
$write_seq->write_seq($seq);
if ($mixed) {
    $write_seq = Bio::SeqIO->new(-file   => ">$outname.consensus_mixed.$parameters.fas",
				 -format => "fasta");				 
    $seq = Bio::Seq->new( -seq => $consensus_mixed,
			  -id  => "$outname.mixed.$parameters");
    $write_seq->write_seq($seq);
}


if ($haplogrep) {
    open HAPLO, ">$outname.haplogrep.$parameters.txt" or die "could not write haplogrep file\n";
    print HAPLO "SampleID\tRange\tHaplogroup\tPolymorphisms\n";
    print HAPLO "$outname\t\"1-16569\"\t?\t$haplo\n";
    close HAPLO;
}

print "#file\tlow_coverage\tlow_support\tlow_coverage(anno)\tlow_support(anno)\n";
print join ("\t", $outname, $stats{"cov"} || 0, $stats{"supp"} || 0, $stats{"anno_cov"} || 0, $stats{"anno_supp"} || 0), "\n";


&graphics;

sub consensus {
    my $position = shift @_;
    unless (exists $data{$position}) {
	return ("N", "", 0);
    }
    my $final_consensus;
    my $lowest_support = 100;
    my $coverage;
    SUBPOS:foreach my $subpos (0 .. 100000) {
	my $currpos;
	if ($subpos == 0) {
	    $currpos = $position;
	} else {
	    $currpos = "$position.$subpos";
	}
	last SUBPOS unless exists $data{$currpos};
	my $total;
	my $current_consensus = "";
	my $current_max = 0;
	foreach my $base (keys %{$data{$currpos}}) {
	    die "weird base: $base \n" unless $base =~ /[ACGT-]/;
	    my $basecount = $data{$currpos}{$base};
	    $total += $basecount;
	    if ($basecount > $current_max) {
		$current_max = $basecount;
		$current_consensus = $base;
	    }
	}
	$coverage = $total if $subpos == 0;
	my $support = $current_max / $total * 100;
	if ($subpos > 0) {
	    my $insertcov = $insertion{$position};
	    my $insertsupp = $total / $insertcov * 100;
	    if ($insertsupp > 50) {
		$lowest_support = $insertsupp;
	    } else {
		my $noinsertsupp = 100 - $insertsupp;
		$lowest_support = $noinsertsupp if $noinsertsupp < $lowest_support;
		next SUBPOS;  #require >50% support for inserts
	    }
	}
	if (exists $data{$currpos}{"-"} && $data{$currpos}{"-"} / $total > 0.5) {#call - if - is >50%
	    $lowest_support = $support if $support < $lowest_support;
	    $final_consensus .= "-";
	} else {
	    if ($total < $mincov) {
		$final_consensus .= "N";
		$lowest_support = $support if $support < $lowest_support;
	    } elsif ($total >= $mincov) {
		if ($support >= $minsupp) {
		    $final_consensus .= $current_consensus;
		    $lowest_support = $support unless $lowest_support < $support;
		} elsif ($support < $minsupp) {
		    $final_consensus .= "N";
		    $lowest_support = $support unless $lowest_support < $support;
		}
	    }
	}
    }
    return ($final_consensus, $lowest_support, $coverage);
}



sub graphics {
    my $y2top = $max_coverage * 1.2;
    print STDERR "\n[consensus_from_bam] generating pdf\n";
        open GNUTEMP, ">gnutemp.delme" or die "could not write temp file for gnuplot";
        print GNUTEMP
"set terminal postscript color
set datafile separator \"\\t\"
set output '$outname.plot.$parameters.ps'
set title (\"Coverage and consensus support \\n$outname\\n$parameters\")
set xlabel 'Position along the reference genome'
set yrange [1:150]
set ylabel 'Consensus support [%]'
set grid
plot '$outname.consensus_support.$parameters.txt' using 1:5 title 'Consensus support' with lines lt 1 lw 2 lc rgb 'black', \\
     '$outname.consensus_support.$parameters.txt' using 1:7 title 'Low support' with points pt 7 lc rgb 'red', \\
     '$outname.consensus_support.$parameters.txt' using 1:6 title 'Low coverage' with points pt 7 lc rgb 'black', \\
     '$outname.consensus_support.$parameters.txt' using 1:9 title 'Annotation' with points pt 7 ps 0.1 lc rgb 'grey'
set yrange [1:$y2top]
set ylabel 'Coverage'
plot '$outname.consensus_support.$parameters.txt' using 1:4 title 'Coverage' with lines lt 1 lw 2 lc rgb 'black'
";
        close GNUTEMP;
        system "gnuplot gnutemp.delme 2>/dev/null";# or die "could not generate plots\n";
        system "ps2pdf $outname.plot.$parameters.ps";
        unlink ("gnutemp.delme", "$outname.plot.$parameters.ps");
}

sub help {
print "

This script takes a bam file and builds a consensus using criteria that can be specified. It outputs a consensus sequence, an alignment of the consensus sequence to the reference genome used for mapping, an input file for haplogrep as well as the consensus support and coverage at each position. This only works on a single chromosome or organelle genome. Indels are called following majority rule. Unmapped reads are disregarded (obviously). 

usage
./consensus_from_bam [-options] bam_file

options
-reference   specify reference genome used for mapping [e.g. /mnt/solexa/Genomes/human_MT/whole_genome.fa]
-support     minimum agreement of sequences with majority base to call a consensus [80]
-coverage    minimum coverage to call consensus [5]
-basequal    disregard bases with phred quality score smaller than X [off]
-mask        disregard T in the first and last X positions of all sequences (or A in reverse complement sequences)  [0]
-uncovered   determine the output in the support field for uncovered positions [120]
-haplogrep   create output file for haplogrep [off]
-mixed       create a mixed consensus where uncalled bases are replaced by the reference state (for iterative mapping strategies)
-annotation  add annotation (provide file from genbank, 'gene features' exportet as fasta)
-help        show this help message

output
-in.consensus.fas              consensus sequence in fasta format
-in.consensus_support.txt      position-wise information
-in.failed_calls.txt           list of positions with failed consensus calls
-in.consensus_data.tab         tabular output for trouble-shooting purposes
";
exit;
}
