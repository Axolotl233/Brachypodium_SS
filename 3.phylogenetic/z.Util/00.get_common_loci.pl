#! perl

use warnings;
use strict;

my %h;
open IN,'<',shift;
while(<IN>){
    next if /#/;
    my @l = split/\t/;
    $h{$l[0]}{$l[1]} = "$l[2],$l[3]";
}
close IN;
open IN,'<',shift;
while(<IN>){
    next if /#/;
    my @l = split/\t/;
    next if !exists $h{$l[0]}{$l[1]};
    next if $h{$l[0]}{$l[1]} ne "$l[2],$l[3]";
    print "$l[0]\t$l[1]\n";
}
close IN;
