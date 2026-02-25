# Coalescent simulation

## Used Programs

* vcftools
* bcftools
* [annovar](https://annovar.openbioinformatics.org/en/latest/)
* [vcflib](https://github.com/vcflib/vcflib/tree/master)
* [easySFS](https://github.com/isaacovercast/easySFS)


## Used public data

* [annovar hg38 refGene](https://annovar.openbioinformatics.org/en/latest/user-guide/download/)
* [USCS annotation for CpG island](https://genome.ucsc.edu/cgi-bin/hgTables?hgta_doSchemaDb=hg38&hgta_doSchemaTable=cpgIslandExt)
* [mask, ancestral, map files](https://myersgroup.github.io/relate/input_data.html#Data)

## preparation of SFS

* remove mono-allele

```sh
vcftools --gzvcf input.vcf.gz --mac 1 --recode --stdout | gzip -c > out.vcf.gz
```

* filter mask regions

```sh
vcftools --gzvcf input.vcf.gz --mask vcftools_mask.fa --recode --stdout | \
gzip -c > output.vcf.gz
```

* filter coding region

```sh
#annovar
perl table_annovar.pl biallele.mask.vcf.gz /path/humandb/ -buildver hg38 -out biallele.mask -remove -protocol refGene -operation g -vcfinput --thread 32 --maxgenethread 32

#get position
zcat biallele.mask.hg38_multianno.vcf.gz | \
awk '$8~/exonic/ {print $1,$2}{OFS="\t"}' >  biallele.mask.hg38.exonic_snps.txt

#filter coding
vcftools --gzvcf biallele.mask.vcf.gz --exclude-positions biallele.mask.hg38.exonic_snps.txt --recode --stdout | \
gzip -c > biallele.mask.noncoding.vcf.gz
```

* filter CpG


