//Parameters for the coalescence simulation program : simcoal.exe
2
//Population effective sizes (number of genes)
NHJMN  //HNDJ
NRJMN   //RYKJ
//Samples sizes and samples age 
18 150
18 80
//Growth rates: negative growth implies population expansion
0
0
//Number of migration matrices : 0 implies no migration between demes
0
//historical event: time, source, sink, migrants, new deme size, growth rate, migr mat index
3 historical event
TBOTHJMN1 0 0 0 HJMNRES1 0 0  //resize HNDJ
TJMNDIV 1 0 1 1 0 0           //RYKJ split from HNDJ
TBOTHJMN2 0 0 0 HJMNRES2 0 0  //resize HNDJ
//Number of independent loci [chromosome] 
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per gen recomb and mut rates
FREQ 1 0 1.25e-8 OUTEXP

