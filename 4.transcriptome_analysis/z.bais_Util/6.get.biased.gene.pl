#! perl

use warnings;
use strict;

my @fs = qw/2.fpkm_compare.CL.txt 2.fpkm_compare.CR.txt 2.fpkm_compare.TL.txt 2.fpkm_compare.TR.txt/;
for my $f(@fs){
    (my $t = $f) =~ s/2.fpkm_compare\.(.*?)\.txt/$1/;
    open O,'>',"$t.gene.lst";
    open IN,'<',$f;
    readline IN;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        next unless $l[5] eq "Normal";
        my @p = split/\-/,$l[2];
        if ($l[4] eq "D_bias"){
            print O $p[1]."\n";
        }elsif($l[4] eq "S_bias"){
            print O $p[0]."\n";
        }
    }
    close O;
}
