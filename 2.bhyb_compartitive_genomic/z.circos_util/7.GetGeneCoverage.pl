#! perl

use warnings;
use strict;
use File::Basename;

if(@ARGV != 3){
    print STDERR "perl $0 \$gff \$karyotype \$window\n";
    exit;
}
(my $gff,my $karyotype,my $window) = @ARGV;
(my $n = basename $karyotype) =~ s/(.*?)\..*/$1/;
my $n_k = $window/1000;

open IN,'<',$karyotype;
my %h;
while(<IN>){
    my @line = split/\s+/,$_;
    $h{$line[2]} = $line[5];
}
close IN;
open IN2,'<',$gff or die "$!";
my %g;
while(<IN2>){
    chomp;
    next if /^$/;
    my @line = split/\t/;
    (my $min,my $max) = &exchang_loc($line[2],$line[3]);
    for(my $i = $min;$i <= $max;$i += 1){
        $g{$i}{$line[0]} += 1;
    }
}
close IN2;
open O,'>',"$n.$n_k"."K.genecov.txt";
for my $key (sort keys %h){
    my $length = $h{$key};
    my $count = 0;
    while($length > 0){
        my $j = 1;
        my $count2 = 0;
        $j = 2 if $length < $window;
        my $start = ($count * $window);
        my $end = ($j == 1)?(($count+1) * $window):$length+$start;
        for(my $i = $start;$i <= $end;$i +=1){
            if(exists $g{$i}{$key}){
	$count2 += 1;
	if($g{$i}{$key} > 1){
	    print STDERR "dup dup dup!\n";
	}
            }
        }
        my $rate = ($count2/$window) * 100;
        print O "$key\t$start\t$end\t$rate\n";
        $count += 1;
        $length = $length - $window;
    }
}
close O;

sub exchang_loc{
    my $n1 = shift @_;
    my $n2 = shift @_;
    if($n1 > $n2){
        my $tmp = $n1;
        $n1 = $n2;
        $n2 = $tmp;
    }
    return ($n1,$n2);
}
