# SNP obtain
described in "1.bsta_resequence/1.reads_to_snp.sh"

# collinearity region identified
minimap2 -cx asm20 --cs -t 30 --secondary=no polyploid_subgenome.fasta diploid.fasta  > z.asm20.paf

# SNP coordinate liftover
transanno minimap2chain z.asm20.paf --output z.asm20.chain
CrossMap.py vcf z.asm20.chain Pop.HDflted.SNP.vcf.gz diploid.fasta Pop.HDflted.2to4.vcf

# SNP to fasta
perl z.Util/00.get_common_loci.pl Pop.HDflted.4.vcf  Pop.HDflted.2to4.vcf > 00.get_common_loci.HDflted.txt
perl z.Util/01.GetFastaFromVCF.pl 00.get_common_loci.HDflted.txt  Pop.HDflted.4.vcf  01.HDflted.4.fa
perl z.Util/01.GetFastaFromVCF.pl 00.get_common_loci.HDflted.txt  Pop.HDflted.2to4.vcf  01.HDflted.2to4.fa
perl z.Util/02.filter_fasta.pl 01.HDflted.4.fa 01.HDflted.2to4.fa > 02.HDflted.fa

#network tree construction
Using split tree v4.0