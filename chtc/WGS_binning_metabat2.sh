#!/bin/bash

# transfer assembly output files
cp /staging/qzhang333/DOdiet_out/assembly_out_$1.tar.gz .
tar -xzf assembly_out_$1.tar.gz
rm assembly_out_$1.tar.gz

# transfer bowtie2 contig mapping bam file
cp /staging/qzhang333/DOdiet_out/contig_align_$1_sorted.bam .

# create metabat2 output dir
mkdir metabat2_out_$1

# Generate a depth file from BAM files
jgi_summarize_bam_contig_depths --outputDepth metabat2_out_$1/depth.txt --referenceFasta assembly_out_$1/$1.contigs.500bp.fasta contig_align_$1_sorted.bam

# Run metabat
metabat2 -i assembly_out_$1/$1.contigs.500bp.fasta -a metabat2_out_$1/depth.txt -o metabat2_out_$1/bin

# compress output 
tar -czf metabat2_out_$1.tar.gz metabat2_out_$1

# move output to staging/qzhang333
mv metabat2_out_$1.tar.gz /staging/qzhang333/DOdiet_out

# clear other data
rm *.bam