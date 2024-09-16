#!/bin/bash

# unpack pipeline 
unzip bowtie2-2.3.4-linux-x86_64.zip
tar -xzf samtools-1.19.tar.gz
tar -xzf bedtools2-2.28.0.tar.gz
tar -xzf python-3.8.tar.gz
tar -xzf python-3.8-packages.tar.gz

# set path
export PATH=$(pwd)/bowtie2-2.3.4-linux-x86_64:$PATH
export BT2_HOME=$(pwd)/bowtie2-2.3.4-linux-x86_64
export PATH=$(pwd)/samtools-1.19/bin:$PATH
export PATH=$(pwd)/bedtools2-2.28.0/bin:$PATH
export PATH=$(pwd)/python-3.8/bin:$PATH
export PYTHONPATH=$(pwd)/python-3.8-packages


# transfer and unpack reads
cp /staging/qzhang333/DOdiet_WGS/$1_R1_trimmed_paired_mouseDNAremoved.fastq.gz .
cp /staging/qzhang333/DOdiet_WGS/$1_R2_trimmed_paired_mouseDNAremoved.fastq.gz .

gzip -d *fastq.gz

# transfer assembly output
cp /staging/qzhang333/DOdiet_out/assembly_out_$1.tar.gz .
tar -zxf assembly_out_$1.tar.gz

# build bowtie2 index
mkdir contig_bowtie2_$1

bowtie2-build assembly_out_$1/$1.contigs.500bp.fasta contig_bowtie2_$1/ref

# alignment WGS reads to contigs
bowtie2 -x contig_bowtie2_$1/ref \
        -1 $1_R1_trimmed_paired_mouseDNAremoved.fastq \
        -2 $1_R2_trimmed_paired_mouseDNAremoved.fastq \
        --local -p 4 |
samtools view -bS > contig_align_$1.bam

# sort bam file
samtools sort contig_align_$1.bam -o contig_align_$1_sorted.bam

# move output to staging/qzhang333
mv contig_align_$1_sorted.bam /staging/qzhang333/DOdiet_out

# clear other data
rm *.bam
rm *.fastq
rm *.tar.gz