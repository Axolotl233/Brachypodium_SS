#! perl

use strict;
use warnings;

my $f1 = "3.stat.between.treatment.L.txt";
my $f2 = "3.stat.between.treatment.R.txt";

my $convert = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression/0.data/Bhyb.wgdi.convert";
my $kaks = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression/0.data/Bhyb.kaks.txt";
my %k = &get_kaks($convert,$kaks);

my %g;
for my $f ($f1,$f2){
    (my $type = $f) =~ s/3.stat.between.treatment\.(.*?)\.txt/$1/;
    open IN,'<',$f;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        @{$g{$l[0]}{$type}} = ($l[1],$l[2],$l[3]);
    }
    close IN;
}

for my $pair (sort {$a cmp $b} keys %g){
    next unless (exists $g{$pair}{L} && exists $g{$pair}{R});
    my @l = @{$g{$pair}{L}};
    my @r = @{$g{$pair}{R}};
    my @p = split /\-/,$pair;
    next unless ($l[0] eq "all" && $r[0] eq "all");
    next unless ($l[1] eq "same" && $r[1] eq "same");
    next unless ($l[2] eq $r[2]);
    
    next unless (exists $k{$p[0]} && exists $k{$p[1]});
    my @k1 = @{$k{$p[0]}};
    my @k2 = @{$k{$p[1]}};
    
    if($l[2] eq "S"){
        print "$p[0]\t",(join"\t",@k1),"\td\tS\n";
        print "$p[1]\t",(join"\t",@k2),"\tu\tD\n";
    }elsif($l[2] eq "D"){
        print "$p[0]\t",(join"\t",@k1),"\tu\tS\n";
        print "$p[1]\t",(join"\t",@k2),"\td\tD\n";
    }else{
        die "$pair\n";
    }
}

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
