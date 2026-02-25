# RyukyuJomon

Repository for Ryukyu Jomon paper

## Analysis
* relate
* fastsimcoal2
* RFmix

### relate

* convert vcf into hap file

```sh
RelateFileFormats --mode ConvertFromVcf \
-i /home/mmatsunami-pg/240828relate/data/URYK_ancient_merged_nomiss_transv_chr${chr} \
--haps /home/mmatsunami-pg/240828relate/input_CHB_JPT/URYK_ancient_merged_nomiss_transv_CHB_JPT_chr${chr}.haps \
--sample /home/mmatsunami-pg/240828relate/input_CHB_JPT/URYK_ancient_merged_nomiss_transv_CHB_JPT_chr${chr}.sample
gzip -f /home/mmatsunami-pg/240828relate/input_CHB_JPT/URYK_ancient_merged_nomiss_transv_CHB_JPT_chr${chr}.haps
gzip -f /home/mmatsunami-pg/240828relate/input_CHB_JPT/URYK_ancient_merged_nomiss_transv_CHB_JPT_chr${chr}.sample
```


### fastsimcoal2


### RFmix




