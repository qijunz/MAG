#!/bin/bash

# unpack pipeline 
tar -xzf kallisto-v0.50.1.tar.gz
tar -xzf python-3.8.tar.gz
tar -xzf python-3.8-packages.tar.gz

# set path
export PATH=$(pwd)/kallisto-v0.50.1:$PATH
export PATH=$(pwd)/python-3.8/bin:$PATH
export PYTHONPATH=$(pwd)/python-3.8-packages

# transfer and unpack reads
cp /staging/qzhang333/DOdiet_WGS/$1_R1_trimmed_paired_mouseDNAremoved.fastq.gz .
cp /staging/qzhang333/DOdiet_WGS/$1_R2_trimmed_paired_mouseDNAremoved.fastq.gz .


# transfer HQ MAG fa files
cp /staging/qzhang333/DOFS_MAG_NR_renamed.fasta .

# run mag_mapping_kallisto.py
mkdir MAG_kallisto_$1

kallisto index -i DOFS_MAG_NR_renamed.idx DOFS_MAG_NR_renamed.fasta
kallisto quant -i DOFS_MAG_NR_renamed.idx -o MAG_kallisto_$1 -t 32 $1_R1_trimmed_paired_mouseDNAremoved.fastq.gz $1_R2_trimmed_paired_mouseDNAremoved.fastq.gz

# tar output 
tar -czf MAG_kallisto_$1.tar.gz MAG_kallisto_$1

# move output to staging/qzhang333
mv MAG_kallisto_$1.tar.gz /staging/qzhang333/DOdiet_out

# clear other data
rm *.idx
rm *.fasta
rm *.tar.gz
rm *.fastq.gz