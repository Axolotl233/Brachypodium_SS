#! perl

use warnings;
use strict;
use File::Basename;

my $dir = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/1.gene_expression/6.stat_between_same_tissue";
my $repeat_data = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/4.repeat_and_expression_relation/01.gene_stat.txt";
my @fs = grep{/.stat.txt/} `find $dir`;
my %pair;
my %gs;
my $c = 0;
for my $f (@fs){
    chomp $f;
    (my $name = basename $f ) =~ s/.stat.txt//;
    open IN,'<',$f;
    while(<IN>){
        my @l = split/\t/;
        next unless $l[1] eq "all";
        next unless $l[2] eq "same";
        my @g = split/\_/,$l[0];
        if(exists $pair{$l[0]}){
            if($pair{$l[0]} ne $l[3]){
	delete $gs{$g[0]};
	delete $gs{$g[1]};
	$c += 1
            }
        }else{
            $pair{$l[0]} = $l[3];
        }
        if($l[3] eq "S"){
            $gs{$g[0]} = "dominant\tS";
            $gs{$g[1]} = "undominant\tD";
        }
        if($l[3] eq "D"){
            $gs{$g[0]} = "undominant\tS";
            $gs{$g[1]} = "dominant\tD";
        }
    }
    close IN;
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
        if (!exists $gs{$l[1]}){
            $gs{$l[1]}= "un_homo_pair\t$l[-1]";
        }
    }
    close IN;
    return %h;
}
