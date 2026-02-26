# Coalescent simulation

## Used Programs

* [vcftools](https://vcftools.github.io/index.html)
* [bcftools](https://samtools.github.io/bcftools/)
* [annovar](https://annovar.openbioinformatics.org/en/latest/)
* [vcflib](https://github.com/vcflib/vcflib/tree/master)
* [easySFS](https://github.com/isaacovercast/easySFS)
* [fastsimcoal2](https://cmpg.unibe.ch/software/fastsimcoal2/)
* [speciation genomics scripts](https://github.com/speciationgenomics/scripts)

## Used public data

* [annovar hg38 refGene](https://annovar.openbioinformatics.org/en/latest/user-guide/download/)
* [USCS annotation for CpG island](https://genome.ucsc.edu/cgi-bin/hgTables?hgta_doSchemaDb=hg38&hgta_doSchemaTable=cpgIslandExt)
* [mask, ancestral, map files](https://myersgroup.github.io/relate/input_data.html#Data)

## preparation of SFS

* remove mono-allele

```sh
vcftools --gzvcf input.vcf.gz --mac 1 --recode --stdout | \
gzip -c > out.vcf.gz
```

* filter mask regions

```sh
vcftools --gzvcf input.vcf.gz --mask vcftools_mask.fa --recode --stdout | \
gzip -c > output.vcf.gz
```

* filter coding region

```sh
#annovar
perl table_annovar.pl biallele.mask.vcf.gz \
/path/humandb/ -buildver hg38 \
-out biallele.mask \
-remove -protocol refGene \
-operation g -vcfinput --thread 32 --maxgenethread 32

#get position
zcat biallele.mask.hg38_multianno.vcf.gz | \
awk '$8~/exonic/ {print $1,$2}{OFS="\t"}' >  \
biallele.mask.hg38.exonic_snps.txt

#filter coding
vcftools --gzvcf biallele.mask.vcf.gz --exclude-positions biallele.mask.hg38.exonic_snps.txt --recode --stdout | \
gzip -c > biallele.mask.noncoding.vcf.gz
```

* filter CpG

```sh
vcftools --gzvcf biallele.mask.noncoding.chr${CHR}.vcf.gz \
--exclude-bed cpgIslandExt.tsv --recode --stdout | \
gzip -c > biallele.mask.noncoding.noCpG.vcf.gz
```

* ancestral alleles were fixed

```sh
bcftools plugin fixref biallele.mask.noncoding.noCpG.vcf.gz \
-O z -o biallele.mask.noncoding.noCpG.ancref.chr${CHR}.vcf.gz \
-- -f homo_sapiens_ancestor.fa -m top
```

* random sampling of SNPs

```sh
bcftools view biallele.mask.noncoding.noCpG.ancref.vcf.gz | \
vcfrandomsample -r 0.07 | \
gzip -c > biallele.mask.noncoding.noCpG.ancref.r007.vcf.gz
#1,719,898 SNPs were sampled
```

* make fold SFS by easySFS

```sh
python easySFS.py \
-i biallele.mask.noncoding.noCpG.ancref.r007.vcf.gz \
-p samples_pop.txt \
--unfolded -a -o outdir --proj=18,18
```

## preparation of SFS for block-bootstraps

```sh
# get all lines with genomic data
zgrep -v "^#" biallele.mask.noncoding.noCpG.ancref.r007.vcf.gz | \
gzip -c > biallele.mask.noncoding.noCpG.ancref.r007.allSites.gz

# get the header
zgrep "^#" biallele.mask.noncoding.noCpG.ancref.r007.vcf.gz > \
biallele.mask.noncoding.noCpG.ancref.r007.header

# get 100 files with 17198 sites each (number 101 removed due to only 98 sites)
gunzip biallele.mask.noncoding.noCpG.ancref.r007.allSites.gz
split -l 17198 biallele.mask.noncoding.noCpG.ancref.r007.allSites \
biallele.mask.noncoding.noCpG.ancref.r007.sites.
rm biallele.mask.noncoding.noCpG.ancref.r007.sites.dw
gzip biallele.mask.noncoding.noCpG.ancref.r007.allSites

#prep sfs file for bootstrap
for NUM in {1..50}; do
	mkdir bs${NUM}
	cat biallele.mask.noncoding.noCpG.ancref.r007.header > \
	bs${NUM}/resampling.bs.${NUM}.vcf

	#Randomly add 100 blocks
	for r in {1..100}; do
		cat `shuf -n1 -e biallele.mask.noncoding.noCpG.ancref.r007.sites.*` >> \
		bs${NUM}/resampling.bs.${NUM}.vcf
	done

	#Compress the vcf file again
	gzip bs${NUM}/resampling.bs.${NUM}.vcf

	phython easySFS.py \
	-i bs${NUM}/resampling.bs.${NUM}.vcf.gz \
	-p samples_pop.txt \
	--unfolded -a \
	-o bs${NUM}/sfs \
	--proj=18,18
done
```
