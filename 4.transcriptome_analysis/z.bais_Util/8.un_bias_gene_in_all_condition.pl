#! perl

use warnings;
use strict;

my @fs = qw/2.fpkm_compare.CR.txt 2.fpkm_compare.TR.txt/;

my %h;
for my $f (@fs){
    (my $t = $f) =~ s/2.fpkm_compare\.(.*?)\.txt/$1/;
    open IN,'<',$f;
    readline IN;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        next if $l[4] ne "no_bias";
        next if $l[5] ne "Normal";
        $h{$l[2]}{$t} = [$l[3],$l[8]];
    }
    close IN;
}

for my $p (sort {$a cmp $b} keys %h){
    my @k = sort {$a cmp $b } keys %{$h{$p}};
    next if (scalar @k != 2);
    print "$p";
    for my $m (@k){
        print "\t";
        print join "\t",@{$h{$p}{$m}};
    }
    print "\n";
}

        
