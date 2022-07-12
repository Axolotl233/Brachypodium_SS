#! perl

use warnings;
use strict;
use File::Basename;

my $dir = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression";
my $repeat_data = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/4.repeat_and_expression_relation/01.gene_stat.txt";

my @fs =qw/3.stat.between.treatment.L.txt 3.stat.between.treatment.R.txt/;
#my @fs = grep{/.stat.txt/} `find $dir`;
my %g;
my %gs;
my $c = 0;
for my $f (@fs){
    chomp $f;
    (my $type = basename $f) =~ s/3.stat.between.treatment\.(.*?)\.txt/$1/;
     #(my $type = $f) =~ s/3.stat.between.treatment\.(.*?)\.txt/$1/;
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
    $c += 1;
    if($l[2] eq "S"){
        $gs{$p[0]} = "dominant\tS";
        $gs{$p[1]} = "undominant\tD";
    }elsif($l[2] eq "D"){
        $gs{$p[0]} = "undominant\tS";
        $gs{$p[1]} = "dominant\tD";
    }else{
        die "$pair\n";
    }

}
my %repeat = &get_repeat($repeat_data);

for my $k (sort {$a cmp $b} keys %gs){
    next if ! exists $repeat{$k};
    print "$k\t".$gs{$k}."\t".$repeat{$k}."\n";

}
print STDERR $c."\n";

sub get_repeat{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        $h{$l[1]} = $l[4];
    }
    close IN;
    return %h;
}
