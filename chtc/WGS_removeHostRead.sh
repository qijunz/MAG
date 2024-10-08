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


# transfer trimmed reads and indexed mouse genome
cp /staging/qzhang333/DOdiet_WGS/$1_R1_trimmomaticTrimmed_paired.fastq.gz .  
cp /staging/qzhang333/DOdiet_WGS/$1_R2_trimmomaticTrimmed_paired.fastq.gz . 
cp /staging/qzhang333/Mus_musculus_GRCm38_Rel98_bowtie2_index.tar.gz .

# uncompress
gunzip $1_R1_trimmomaticTrimmed_paired.fastq.gz
gunzip $1_R2_trimmomaticTrimmed_paired.fastq.gz
tar -xzf Mus_musculus_GRCm38_Rel98_bowtie2_index.tar.gz

# alignment WGS reads to mouse genome
bowtie2 -x Mus_musculus_GRCm38_Rel98_bowtie2_index/ref \
        -1 $1_R1_trimmomaticTrimmed_paired.fastq \
        -2 $1_R2_trimmomaticTrimmed_paired.fastq \
        --local -p 1 |
samtools view -bS > $1_mouseGenome_align.bam

# get mouse genome unmapped sam file
samtools view -b -f 4 -f 8 -o $1_mouseDNA_unmapped.bam $1_mouseGenome_align.bam

# sort unmapped bam file
samtools sort -n $1_mouseDNA_unmapped.bam -o $1_mouseDNA_unmapped_sorted.bam
rm $1_mouseDNA_unmapped.bam

>&2 echo "flagstat of sorted bam file: "
>&2 samtools flagstat $1_mouseDNA_unmapped_sorted.bam

# extract unmapped reads from bam file
bamToFastq -i $1_mouseDNA_unmapped_sorted.bam \
           -fq $1_R1_trimmed_paired_mouseDNAremoved.fastq \
           -fq2 $1_R2_trimmed_paired_mouseDNAremoved.fastq

# compress fastq data
gzip -f $1_R1_trimmed_paired_mouseDNAremoved.fastq
gzip -f $1_R2_trimmed_paired_mouseDNAremoved.fastq

# transfer reconstruct unmapped and mapped reads into gluster
mv $1_R1_trimmed_paired_mouseDNAremoved.fastq.gz /staging/qzhang333/DOdiet_WGS/
mv $1_R2_trimmed_paired_mouseDNAremoved.fastq.gz /staging/qzhang333/DOdiet_WGS/

# clear data
rm *.tar.gz
rm *.fastq
rm *.bam