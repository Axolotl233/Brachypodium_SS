#! perl

use strict;
use warnings;

my $f = shift;

my $convert = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression/0.data/Bhyb.wgdi.convert";
my $kaks = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression/0.data/Bhyb.kaks.txt";
my %k = &get_kaks($convert,$kaks);
my %g;

open IN,'<',$f;
#print "Gene\tNG86\tYN00\tSubgenome\n";
while(<IN>){
    chomp;
    my @l = split/\t/;
    if(exists $k{$l[0]}){
        print "$l[0]\t";
        print join"\t",@{$k{$l[0]}};
        print "\tS\n";
    }
    #if(exists $k{$l[1]}){
    #    print "$l[1]\t";
    #    print join"\t",@{$k{$l[1]}};
    #    print "\tD\n";
    #}
}
close IN;

sub get_kaks{
    my $b1 = "/data/01/user112/project/Brachypodium/07.evo/04.wgdi/run/BhD-Bdis/BhD-Bdis.alignment.csv";
    my $b2 = "/data/01/user112/project/Brachypodium/07.evo/04.wgdi/run/BhS-Bsta/BhS-Bsta.alignment.csv";
    my %r;
    for my $b ($b1,$b2){
        open IN,'<',$b;
        while(<IN>){
            chomp;
            my @l = split/,/;
            next if @l == 1;
            next if $l[1] eq "\.";
            $r{"$l[0]-$l[1]"} = 1;
            $r{"$l[1]-$l[0]"} = 1;
        }
        close IN;
    }
    my $f1 = shift @_;
    my $f2 = shift @_;
    my %c;
    open IN,'<',$f1;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        $c{$l[0]} = $l[1];
    }
    close IN;
    my %h;
    my $d = 0;
    open IN,'<',$f2;
    D:while(<IN>){
        chomp;
        my @l = split/\t/;
        next if scalar @l != 6;
        my $g = $c{$l[0]};
        next if !exists $r{"$l[0]-$l[1]"} && !exists $r{"$l[1]-$l[0]"};
          if ($l[-1] eq "-0.0"){
            $h{$g} = ["no_ks","no_ks"];
            next D;
        }
        my $kaks_ng86 = $l[2]/$l[3];
        my $kaks_yn00 = $l[4]/$l[5];
        $d += 1 if exists $h{$g};
        $h{$g} = [$kaks_ng86,$kaks_yn00];
    }
    close IN;
    print STDERR $d;
    return %h;
}
