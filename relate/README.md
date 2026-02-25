## relate

* convert vcf into hap file

```sh
PrepareInputFiles.sh \
--haps input.haps.gz \
--sample input.sample.gz \
--ancestor homo_sapiens_ancestor_GRCh38.fa \
--mask StrictMask.fa.gz \
--remove_ids remove_IDs.txt \
-o converted_ouput
```

* prepare relate input file

```sh
PrepareInputFiles.sh \
--haps converted_ouput.haps.gz \
--sample converted_ouput.sample.gz \
--ancestor homo_sapiens_ancestor_GRCh38.fa \
--maskStrictMask.fa.gz.fa.gz \
--remove_ids remove_IDs.txt \
-o relate_input
```

* execute relate

```sh
RelateParallel.sh \
--haps relate_input.haps.gz \
--sample relate_input.sample.gz \
--dist relate_input.dist.gz \
--map genetic_map_GRCh38.txt \
-m 1.25e-8 -N 20000 \
--coal 1000G_auto.coal \
--sample_ages age.txt \
-o relate_result
```
