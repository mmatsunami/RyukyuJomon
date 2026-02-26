# Local ancestral inferences

### Used Programs

* [RFmix](https://github.com/slowkoni/rfmix)
* [karyoploteR (R library) ](https://github.com/bernatgel/karyoploteR)

### prep centromere file by R

```R
library(karyoploteR)
kp <- plotKaryotype(chromosomes="autosomal", genome="hg38")
out <- kp$cytobands[kp$cytobands$gieStain == "acen",]
write.table(out, "hg38.acen.txt", sep="\t", quote=F)
```

### Local ancestral inferences by RFmix

```sh
for POP in {JPT,OKI}; do
	for CHR in {1..22}; do
		rfmix -f ${POP}.chr${CHR}.vcf.gz \
		-r CHB_JMN.chr${CHR}.vcf.gz \
		-m CHB_JMN.samples.tsv \
		-g RFMix.chr${CHR}.GRCh38.map \
		-o ${POP}.deconvoluted.chr${CHR} \
		--chromosome=${CHR} \
		--n-threads=24
	done
done
```

### filter centromere

```sh
for POP in {JPT,OKI}; do
	for CHR in {1..22}; do
		perl filter_centromere.pl hg38.acen.txt \
		${POP}.deconvoluted.chr${CHR}.msp.tsv > \
		${POP}.deconvoluted.filter.chr${CHR}.msp.tsv
	done
done
```

### summarize results

```sh
for POP in {JPT,OKI}; do
	for CHR in {1..22}; do
		cat ${POP}.deconvoluted.filter.chr${CHR}.msp.tsv | \
		awk -F "\t" 'NR==2{print $1,$2,$3,$4,$5,$6,"sum","norm_sum"}NR>2{ sum=0; for (i=7; i<=NF; i++) { sum+=$i } print $1,$2,$3,$4,$5,$6,sum,sum/210; }{OFS="\t"}' > \
		${POP}.deconvoluted.filter.chr${CHR}.msp.sum.tsv
	done

	cat ${POP}.deconvoluted.filter.chr${CHR}.msp.sum.tsv > \
	${POP}.deconvoluted.filter.msp.sum.tsv
	for CHR in {2..22}; do 
		cat ${POP}.deconvoluted.filter.chr${CHR}.msp.sum.tsv | \
		sed '1,1d' >> ${POP}.deconvoluted.filter.msp.sum.tsv
	done
	gzip ${POP}.deconvoluted.filter.msp.sum.tsv
done
```

### plot by R

```R
library(karyoploteR)

JPT <- read.delim("JPT.deconvoluted.filter.msp.sum.tsv.gz", sep="\t", head=T)
OKI <- read.delim("OKI.deconvoluted.filter.msp.sum.tsv.gz", sep="\t", head=T)

jpeg('JPT_OKI.RFmix.jpeg', width = 2048, height = 1536, quality = 100)
kp <- plotKaryotype(chromosomes="autosomal", genome="hg38", plot.type=2)
kpRect(kp, chr=paste0("chr",JPT$X.chm), x0=JPT$spos, x1=JPT$epos, y0=0, y1=JPT$norm_sum*2, col="blue", data.panel = 1)
kpAxis(kp, ymin = 0, ymax=0.5, data.panel = 1)
kpRect(kp, chr=paste0("chr",OKI$X.chm), x0=OKI$spos, x1=OKI$epos, y0=0, y1=OKI$norm_sum*2, col="red", data.panel = 2)
dev.off()
```
