#! perl

use warnings;
use strict;

open IN,'<',shift;
my $thre =shift;
$thre //= 0.01;
open O,'>',"$0.R";
while(<IN>){
    chomp;
    my @l = split/\t/;
    my @t = split/,/,$l[2];
    #my @T = &cal_T(@t);
    #@T = grep{$_>5} @T;
    #open O,'>',"$0.R";
    print O "c(\"$l[0]:$l[1]:$l[2]\")\n";
    print O "R <- matrix(c($l[2]),nrow=2,ncol=2)\n";
    #if(scalar @T < 4){
        print O "a <- fisher.test(R)\nprint (a)\n";
     #   close O;
     #   my $a = `Rscript $0.R`;
     #   &print_fisher($a);
    #}else{
     #   print O "a <- chisq.test(R)\nprint (a)\n";
      #  close O;
      #  my $a = `Rscript $0.R`;
      #  &print_chisq($a);
    #}
}
close O;
my $a = `Rscript $0.R`;
&print_fisher($a);
#unlink "$0.R";

sub print_chisq{
    my $a = shift @_;
    my @l = split/\n/,$a;
    my $p;
    for(@l){
        chomp;
        if(/^\[1\]/){
            s/^\[1\]\s+//;
            s/"//g;
            my @line = split/:/;
            $p =  join"\t",@line;
        }else {
            next if /^\s/;
            if(/X-squared/){
	my @line = split/,/;
	$line[2] =~ s/.*\s//;
	$p .= "\t".$line[2]."\tchisq\n";
	if($line[2] < $thre){
	    print $p;
	}
	$p = ""
            }
        }
    }
}

sub print_fisher{
    my $a = shift @_;
    my @l = split/\n/,$a;
    my $p;
    for(@l){
        chomp;
        if(/^\[1\]/){
            s/^\[1\]\s+//;
            s/"//g;
            my @line = split/:/;
            $p = join"\t",@line;
        }else {
            next if /^\s/;
            if(/p-value/){
	my @line = split/\s/;
	$line[1] =~ s/.*\s//;
	$p .= "\t".$line[2]."\tfisher\n";
	if($line[2] < $thre){
	    print $p;
	}
	$p = "";
            }
        }
    }
}
  
sub cal_T{
    my @a = @_;
    my @r;
    my $sum = $a[0] + $a[1] + $a[2] + $a[3];
    push @r, ($a[0]+$a[1])*($a[0]*$a[2])/$sum;
    push @r, ($a[1]+$a[3])*($a[1]+$a[0])/$sum;
    push @r, ($a[2]+$a[0])*($a[2]+$a[3])/$sum;
    push @r, ($a[2]+$a[3])*($a[1]+$a[3])/$sum;
    return @r;
}
