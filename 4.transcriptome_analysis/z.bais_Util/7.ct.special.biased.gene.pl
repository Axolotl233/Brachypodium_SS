#! perl

use warnings;
use strict;

my @fs = qw/3.stat.between.treatment.L.txt 3.stat.between.treatment.R.txt/;
for my $f(@fs){
    (my $t = $f) =~ s/3.stat.between.treatment\.(.*?)\.txt/$1/;
    open IN,'<',$f;
    my %h;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        my @p = split/\-/,$l[0];
        if($l[1] eq "all"){
            next unless $l[2] eq "same";
            if($l[3] eq "S"){
	push @{$h{$l[1]}} , $p[0];
            }elsif ($l[3] eq "D"){
	push @{$h{$l[1]}} , $p[1];
            }
        }else{
            if($l[3] eq "S"){
	push @{$h{$l[1]}} , $p[0];
            }elsif ($l[3] eq "D"){
	push @{$h{$l[1]}} , $p[1];
            }
        }
    }
    close IN;
    for my $k (keys %h){
        open O,'>',"$t.$k.gene.lst";
        my @p = @{$h{$k}};
        print O join"\n",@p;
        print O "\n";
        close O;
    }
}
