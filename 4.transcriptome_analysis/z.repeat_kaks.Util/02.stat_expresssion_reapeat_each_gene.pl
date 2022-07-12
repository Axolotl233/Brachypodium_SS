#! perl

use warnings;
use strict;
use List::Util qw (sum);

my $sample_lst = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/4.repeat_and_expression_relation/00.data/Sample.txt";
my $count_data = "/data/01/user112/project/Brachypodium/09.trans/bhyb/03.Martix4Deseq2/gene_count_matrix.csv";
my $repeat_data = "/data/01/user112/project/Brachypodium/07.evo/07.bhyb_subgenome_bias/4.repeat_and_expression_relation/01.gene_stat.txt";
my $tpm_data = "/data/01/user112/project/Brachypodium/09.trans/bhyb/02.stringtie/Bhyb.tpm.txt";

my %sample = &get_sample($sample_lst);
#my %gene = &get_count($count_data,\%sample);
my %gene = &get_count2($tpm_data,\%sample);
my %repeat = &get_repeat($repeat_data);

for my $k(sort{$a cmp $b} keys %gene){
    next if ! exists $repeat{$k};
    print "$k\t".$gene{$k}."\t".$repeat{$k}."\n";
}

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

sub get_count2{

    my $f = shift @_;
    my $ref = shift @_;
    my %s = %{$ref};
    my %h;
    open IN,'<',$f;
    my $first = readline IN;
    my @head = split/\t/,$first;
    while(<IN>){
        chomp;
        my @l = split/\t/;
        my @t;
        for(my $i = 1 ;$i < @l;$i++){
            if(exists $s{$head[$i]}){
	push @t , $l[$i];
            }
        }
        next unless sum(@t) == 0;
        my $mean = (sum(@t))/(scalar @t);
        #$mean = 0.00001 if $mean ==0;
        $h{$l[0]} = $mean;
    }
    close IN;
    return %h;
}

sub get_count{

    my $f = shift @_;
    my $ref = shift @_;
    my %s = %{$ref};
    my %h;
    open IN,'<',$f;
    my $first = readline IN;
    my @head = split/,/,$first;
    while(<IN>){
        chomp;
        my @l = split/,/;
        my @t;
        for(my $i = 1 ;$i < @l;$i++){
            if(exists $s{$head[$i]}){
	push @t , $l[$i];
            }
        };
        next if sum(@t) < 3;
        my $mean = (sum(@t))/(scalar @t);
        $h{$l[0]} = $mean;
    }
    return %h;
    close IN;
}

sub get_sample{
    my $f = shift @_;
    my %h;
    open IN,'<',$f;
    while(<IN>){
        chomp;
        my @l = split/\s+/;
        $h{$l[0]} = 1;
    }
    close IN;
    return %h;
}
