# chloroplast assembly
get_organelle_from_reads.py -1 sample_fix_1.fastq.gz -2 sample_2.fastq.gz -o TE43 -t 20 -R 15 -k 21,45,65,85,105 -F embplant_pt

# annotation
perl PGA.pl -r z.database/gb -t annotation

# gb to cds
perl z.Util/genbank2CDSandPEP.pl sample.gb sample

# ML tree construction
perl z.Util/0.sample2gene.pl
perl z.Util/1.mafft.pl |sh and mannual removed gene which have been wrong annotated
perl z.Util/2.tandem_fa.pl
iqtree -s All.plast.gene.fasta  -pre fix -nt 10 -bb 1000 -quiet -redo
