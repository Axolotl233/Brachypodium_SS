#!/usr/bin/env perl
#===============================================================================
#
#         FILE: Dxy.po
#
#        USAGE: ./Dxy.pl  
#
#  DESCRIPTION: 
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Zeyu Zheng (Lanzhou University), zhengzy2014@lzu.edu.cn
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 1/3/2018 08:22:03 PM
#     REVISION: ---
#===============================================================================
# based on ## Author: Ke Bi (ke@berkeley.edu) : PopGenomics.pl

use v5.24;
use strict;
use warnings;
use Getopt::Std;
#use Getopt::Long;
#use File::Basename;
use Math::Trig;
#use feature "refaliasing";
#no warnings "experimental::refaliasing";
#use Geo::Proj4;
#use List::Util qw[min max];
use MCE::Loop;
#use FileHandle;


die(qq/
	Dxy.pl [options]

	options:

	-g  FILE  vcf(gz) file
	-p  FILE  pop_list_file
	-o  FILE  outfiles prefix dir(path)
	-w  INT   Window size
	-s  INT   Step Size
	-h  FILE  ref_header(xx.dict)

	pop_list_file looks like: 
		pop1 pop1_individuals_id 
		pop2 pop2_individuals_id 
		...

		eg: CladeA HH1-1 HH2
	\n\n/) unless (@ARGV);


my %opts = (g=>undef, p=>undef, o=>undef, w=>undef, 's'=>undef, h=>undef);
getopts('g:p:o:w:s:h:', \%opts);


my $genofile = $opts{g};
my $pop_file = $opts{p};
my $out_prefix = $opts{o};
my $window = $opts{w};
my $step = $opts{'s'};
my %chrs_len = &read_ref_herder( $opts{h} );


$step = $window unless (defined $step && $step>0);

my %fh;
my %pops=&read_pop_file($pop_file);
&open_fh(\%pops, $out_prefix);
my %prob = &cal_prob(\%pops);

&Dxy;
exit;

sub Dxy {
    
    if ($genofile=~/\.gz$/)  {
        open (GENO, "zcat $genofile |") or die "$!";
    }else {
        open (GENO, "<", $genofile) or die "$!";
    }
    
    my %Pop2IdNum;
    
    
    #my $i=0;
    my $min=0;
    my $max=$min+$window;
    my $min_next = $min + $step;
    my $chr_old='';
    my %pop_gene;
    my %pop_gene_next;
    my $i_chr=0;
    my $chr_all_num=scalar keys %chrs_len;
    while (<GENO>) {
        ##  VCF:
        ##   0    1   2  3    4   5      6     7    8      9...
        ## CHROM POS ID REF  ALT QUAL FILTER INFO FORMAT
        if (/^#/) {
            next if /^##/;
            if (/^#/) {
	chomp;
	my @a=split(/\s+/,$_);
	foreach my $n(9..@a-1) {
	    foreach my $pop (keys %pops) {
	        push ( @{ $Pop2IdNum{$pop} } , $n ) if $a[$n] ~~ @{ $pops{$pop} };
	    }
	}
	last;
            }
        }
        die "???\n $!";
    }
    while (<GENO>) {
        ## geno2:
        ## scaffold92  38  T  C  -1  0
        ##   0          1  2  3   4  5
        chomp;
        my @line = split (/\s+/, $_);
        next unless @line;
        my $chr = $line[0];
        my $pos = $line[1];
        foreach my $ii (9..@line-1) {
            if ($line[$ii]=~/^(\d)\/(\d)/) {
	die " !!!! $1 / $2\n" if ($1>1 || $2>1);
	$line[$ii] = $1 + $2;
	next;
            }else {
	$line[$ii] = -1;
            }
        }
        if ( $chr ne $chr_old ) {
            $i_chr++;
            say "now processing: $chr , $i_chr / $chr_all_num";
            &do_dxy($chr_old, $min, $max, \%pop_gene) if ( %pop_gene && $chr_old);
            %pop_gene=();
            $min=1;
            $max=$min+$window-1;
            $chr_old=$chr;
            redo;
        }
        if ( $pos >= $min ) {
            if ($pos <= $max) {
	foreach my $pop(keys %pops) {
	    push ( @{ $pop_gene{$pop}{$pos} },  @line[ @{ $Pop2IdNum{$pop} } ] ) ;
	}
	if ($pos >= $min_next) {
	    foreach my $pop(keys %pops) {
	        push ( @{ $pop_gene_next{$pop}{$pos} },  @line[ @{ $Pop2IdNum{$pop} } ] ) ;
	    }
	}	
            }else {
	$min+=$step;
	$max+=$step;
	&do_dxy($chr_old, $min, $max, \%pop_gene);
	%pop_gene= %pop_gene_next;
	%pop_gene_next = ();
	#$i++;
	redo;
            }
        }else {
            die "???? do you sorted? $chr $pos ???\n";
        }
        
        
    }
    close GENO;
    
    
    
}


sub read_pop_file() {
    my ($pop_file)=@_;
    my $P;
    my %pops;
    open ($P,"< $pop_file") or die "$!";
    while (<$P>) {
        chomp;
        next unless $_;
        my @a=split(/\s+/,$_);
        my $pop_now=shift @a;
        # $pops{$pop_now}  = \@a;
        push (@{$pops{$pop_now}}, @a);
    }
    close $P;
    return %pops;
}

sub cal_prob() {
    my %pops=%{$_[0]};
    my %prob;
    foreach my $pop1 (sort keys %pops) {
        my $done=0;
        foreach my $pop2 (sort keys %pops) {
            if ($pop1 eq $pop2) {
	$done=1;
	next;
            }
            next if $done == 0;
            $prob{$pop1}{$pop2} = scalar(@{ $pops{$pop1} }) * scalar(@{ $pops{$pop2} }) * 2 * 2;
            # say $prob{$pop1}{$pop2} ;
        }
    }
    return %prob;
}


sub open_fh() {
    my %pops=%{$_[0]};
    my $prefix=$_[1];
    foreach my $pop1 (sort keys %pops) {
        my $done=0;
        foreach my $pop2 (sort keys %pops) {
            if ($pop1 eq $pop2) {
	$done=1;
	next;
            }
            next if $done == 0;
            my $out="$prefix.$pop1.$pop2";
            say $out;
            open ($fh{$pop1}{$pop2}, "> $out") or die "Can't open $out, $!";
            $fh{$pop1}{$pop2} -> print ("CHROM\tBIN_START\tBIN_END\tDXY\n");
        }
    }
}

sub do_dxy() {
    my ($chr_now, $start_now, $end_now, %pop_gene_now) = ($_[0], $_[1], $_[2], %{$_[3]});
    foreach my $pop1 (sort keys %pop_gene_now) {
        my $done=0;
        foreach my $pop2 (sort keys %pop_gene_now) {
            if ($pop1 eq $pop2) {
	$done=1;
	next;
            }
            next if $done == 0;
            my $dxy_now = do_dxy_by_chr( $pop_gene_now{$pop1} , $pop_gene_now{$pop2} );
            $dxy_now = $dxy_now / $prob{$pop1}{$pop2};
            if ($chrs_len{$chr_now} > $end_now) {
	$dxy_now = $dxy_now / $window;
            } else {
	$dxy_now = $dxy_now / ( $chrs_len{$chr_now} - $start_now );
            }
            #$fh{$pop1}{$pop2} -> printf ("%s\t%d\t%d\t%.5f\n", $chr_now, $start_now, $end_now, $dxy_now);
            $fh{$pop1}{$pop2} -> print ("$chr_now\t$start_now\t$end_now\t$dxy_now\n");
            
        }
    }
}

sub read_ref_herder() {
    my ($file)=@_;
    my %chrs_len;
    my $I;
    open ($I,"<$file") or die "no $file, $!";
    while(<$I>) {
        next unless /^\@SQ/;
        chomp;
        /SN:(\S*)\s+LN:(\d+)/;
        $chrs_len{$1} = $2;
        #push (@chrs, $1);
	}
    close $I;
    return %chrs_len;
}


sub do_dxy_by_chr() {
    my %p1_by_chr=%{ $_[0] };
    my %p2_by_chr=%{ $_[1] };
    my $count_all=0;
    my %Dxy_by_Chr;
    
    foreach my $pos (sort {$a <=> $b} keys %p1_by_chr) {
        my $n=0;
        
        foreach my $geno1 (@{$p1_by_chr{$pos}}) {
            next if $geno1 == -1;
            
            foreach my $geno2 (@{$p2_by_chr{$pos}}) {
	next if $geno2 == -1;
	if ($geno1 == $geno2) {
	    if ($geno1 == 1) {
	        $n += 1;
	    }else { #$geno1 != 1
	        $n += 0;
					}
	} else { # if ($geno1 != $geno2) 
	    $n += abs($geno1-$geno2);
	}
            }
        }
        #$all_temp += $n/$count if ($count > 0 ) ;
        #$sites_temp ++  if ($count > 0 ) ;
        $count_all += $n;
    }
    return $count_all;    
}



