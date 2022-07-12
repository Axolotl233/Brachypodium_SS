# Pi
vcftools --gzvcf Pop.final.SNP.filter.vcf.gz --keep ../AS.pop --out Pi.AS.lst.50K.12.5K --window-pi 50000 --window-pi-step 12500
vcftools --gzvcf Pop.final.SNP.filter.vcf.gz --keep ../ES.pop --out Pi.ES.lst.50K.12.5K --window-pi 50000 --window-pi-step 12500

#LD
PopLDdecay -InVCF ./Pop.final.SNP.filter.vcf.gz -OutStat Pop.ld.ES -SubPop ./ES.pop -MaxDist 5000
PopLDdecay -InVCF ./Pop.final.SNP.filter.vcf.gz -OutStat Pop.ld.AS -SubPop ./AS.pop -MaxDist 5000

#Fis and S
Using https://github.com/Axolotl233/Simple_Script/blob/master/Command.Plink.F.pl

#FST
Using https://github.com/Axolotl233/Simple_Script/blob/master/Vcf.fst.v2.pl

#DXY
Using z.Util/Dxy.pl

#HKA
Using z.Util/HKA.stat.fix_site.pl and z.Util/HKA.fisher.test.pl

#gene_anno
Using https://github.com/Axolotl233/Simple_Script/blob/master/Vcf.anno.bed.window.pl
