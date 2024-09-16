## MAG analysis pipeline

This pipeline is Qijun Zhang's use for metagenomic and metatranscriptomic analysis using shotgun sequencing reads.

The quantitative output for microbial phenotype is the MAG (Metagenome-assembled genomes) abundance and microbial transcripts abundance of MAG genes.

## Steps

The input data for this pipeline should be high-quality shotgun reads (fastq format).

### [1] Remove host reads

The shotgun sequencing usually contain host contamination reads, the proportion of host reads vary from sample to sample (e.g., human vs. mouse, diets also impact)

- First, reads are aligned against the mouse genome (mm10/GRCm38) or human genome (GRCh38) using Bowtie2 (`--local`).

- Then, reads that were not aligned to the host genome were identified using samtools (`samtools view -b -f 4 -f 8`). 

One example for this step running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/WGS_removeHostRead.sh`.


### [2] *de novo* assembly

Assemble short sequencing reads into longer fragment is the central step to generate MAGs. There are many different assemblers that people use. Here is the example using [SPAdes](https://github.com/ablab/spades). 

- First, the clean microbial reads from each sample are assembled into contigs using SPAdes (`metaspades.py -k 21,33,55,77`).

- Then, any contigs short than 500bp are discorded. You can customize this cutoff. 

One example for this step running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/WGS_assembly.sh`.

### [3] Contigs binning into MAG

The assembled contigs are usually genome fragments, contigs binning can generate bacteria genomes (i.e., MAGs). There are several different binning tools people use, some studies consider using different binning tools and combine MAGs. Here is the example using [MetaBAT2](https://bioconda.github.io/recipes/metabat2/README.html).

- Many binning tools consider contigs abundance as the MAG features. So first step is to map shotgun reads to assembled contigs in each samples. One example running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/WGS_mapping_contigs.sh`.

- Next, provided the sorted `.bam` file of reads mapping to contigs and the contigs sequence files, MetaBAT2 (default parameters) are used for contigs binning. One example running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/WGS_binning_metabat2.sh`.


### [4] MAG quality control and dereplication

The output of MetaBat2 are all the bins identified. Because the assembly are performed in single samples, redundant MAGs may exist among different samples.

- To assess MAGs quality, [CheckM](https://github.com/Ecogenomics/CheckM) (`checkm lineage_wf`) is used to estimate genome completeness and contamination for each MAG. The high-quality MAGs are usually defined as "completeness > 90% and contamination < 5%"

- The high-quality MAGs were dereplicated using [dRep](https://github.com/MrOlm/drep) (`-pa 0.9 -sa 0.99`). 

- In each secondary clusters of dRep output, the representative MAGs are chosen by the highest score. The MAG score is defined as (with default parameters from dRep):

>  A\*Completeness - B\*Contamination + C\*(Contamination * (strain_heterogeneity/100)) + D\*log(N50) + E\*log(size) + F\*(centrality - S_ani)

> default: A=1, B=5, C=1, D=0.5, E=0, F=1


The output of this step is the final set of high-quality non-redundant MAGs (completeness > 90%, contamination < 5% and average nucleotide identity (ANI) > 99%). One example for this step running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/MAG_checkm.sh` and `chtc/MAG_drep.sh`.

### [5] MAG taxonomy classification

Taxonomic assignments of these 436 MAGs were using the Genome Taxonomy Database Toolkit ([GTDB-Tk](https://github.com/Ecogenomics/GTDBTk)) and the GTDB database. One example running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/MAG_gtdbtk.sh`.


### [6] MAG gene identification and annotation

With full sequence of MAG, genes can be predicted and annotated to different database.

- First, in each MAG, genes (i.e., open reading frames) are predicted using [Prodigal](https://github.com/hyattpd/Prodigal) and annotated using [Prokka](https://github.com/tseemann/prokka), which give the gene categories (e.g., CDS, rRNA, tRNA, tmRNA).
- Then, the predicted genes can be annotated aginist [KEGG](https://www.genome.jp/kegg/), [CAZyme](http://www.cazy.org/) and [pfam](http://pfam.xfam.org/) etc.
- For example, genes can be annotated to KEGG using [hmmer](http://hmmer.org/) and [kofam](https://github.com/takaram/kofam_scan) database.

One example for this step running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/MAG_prokka.sh` and `chtc/MAG_gene_kofam.sh`.

### [7] Estimate MAG and MAG gene abundance

To get quantitative microbial phenotypes, MAG and MAG gene abundances can be estimated by mapping shotgun DNA/RNA reads to MAG/MAG genes. Here is example using pseudo-alignment tool [kallisto](https://github.com/pachterlab/kallisto).

- To estimate MAG abundance, a single kallisto index using all MAG sequences can be generated (`kallisto index`).

- To estimate MAG gene abundance, a single kallisto index using all gene sequences can be generated (`kallisto index`).

- MAG or MAG gene abundance then can be estimated using `kallisto quant`.

One example for this step running on [CHTC](https://chtc.cs.wisc.edu/) is showed in `chtc/MAG_kallisto.sh`.


## Contact
**Qijun Zhang** (qijun0507@gmail.com)