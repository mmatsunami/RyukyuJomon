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

* estimate population size

```sh
RelateCoalescentRate \
--mode EstimatePopulationSize \
-i relate_result \
-o relate_estimate_pop \
--first_chr 1 \
--last_chr 22 \
-m 1.25e-8 --bins 3,7,0.1 \
--poplabels relate_result.poplabels
```

* plot

```R
library(ggplot2)
library(grid)
library(gridExtra)
library(scales)

filename <- "relate_estimate_pop"
years_per_gen <- as.numeric("28")

#read in population size
groups   <- as.matrix(read.table(paste(filename, ".coal", sep = ""), nrow = 1))
t        <- years_per_gen*t(as.matrix(read.table(paste(filename, ".coal", sep = ""), skip = 1, nrow = 1)))
pop_size <- data.frame(time = numeric(0), pop_size = numeric(0), groups = numeric(0))
num_pops <- round(sqrt(dim(read.table(paste(filename, ".coal", sep = ""), skip = 2))[1]))
#num_pops <- (-1 + sqrt(1 + 8 * num_pops))/2

for(p1 in 1:num_pops){
  for(p2 in 1:p1){
    c        <- as.matrix(read.table(paste(filename, ".coal", sep = ""), skip = (p1-1) * num_pops + p2 + 1, nrow = 1))[-c(1:2)]
    str      <- rep(paste(groups[p1]," - ",groups[p2], sep = ""),length(c))
    pop_size <- rbind(pop_size, data.frame(time = t, pop_size = 0.5/c, groups = str))
  }
}
pop_size$time[which(pop_size$time > 1e7)] <- 1e7

ggplot(pop_size, aes(x = time, y=pop_size, colour=groups)) +
geom_step(lwd = 1.5) +
annotation_logticks(sides = "b") +  
scale_x_log10(breaks = 10^(3:7),labels = trans_format("log10", math_format(10^.x)), minor_breaks = log10(5) + 3:7) +
#scale_x_continuous(limits = c(1e3,1e7), trans="log10") + 
#ylim(c(0, 50000)) +
scale_y_continuous(limits = c(0,50000)) +
ylab("population size") +
xlab("years ago") +
theme_classic(base_size = 24)+
theme(legend.position="none")
ggsave(file="pop_size.jpeg", width = 11.69, height = 8.27, dpi = 300)
```
