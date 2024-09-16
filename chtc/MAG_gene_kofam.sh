#!/bin/bash

# unpack pipeline 
tar -xzf hmmer-3.4.tar.gz
tar -xzf kofam_scan-1.3.0.tar.gz

mkdir ruby
mkdir parallel

# set path
export PATH=$(pwd)/hmmer-3.4/bin:$PATH
export PATH=$(pwd)/kofam_scan-1.3.0:$PATH
export PATH=$(pwd)/ruby/bin:$PATH
export PATH=$(pwd)/parallel/bin:$PATH

# transfer kofam db
cp /staging/qzhang333/kofam_20231127/profiles.tar.gz .
cp /staging/qzhang333/kofam_20231127/ko_list.gz .

gunzip ko_list.gz
tar -xzf profiles.tar.gz


# install and compile Ruby
>&2 echo "downloading ruby from website...."
wget https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.0.tar.gz

>&2 echo "unpacking ruby source code..."
tar -xzvf ruby-2.7.0.tar.gz
cd ruby-2.7.0

>&2 echo "compiling ruby source code (configure)..."
./configure --prefix=$(pwd)/../ruby/

>&2 echo "compiling ruby source code (make)..."
make

>&2 echo "compiling ruby source code (make install)..."
make install
cd ..

# install and compile parallel
>&2 echo "downloading parallel from website...."
wget https://ftp.gnu.org/gnu/parallel/parallel-20231122.tar.bz2

>&2 echo "unpacking parallel source code..."
tar -xvjf parallel-20231122.tar.bz2
cd parallel-20231122

>&2 echo "compiling parallel source code (configure)..."
./configure --prefix=$(pwd)/../parallel/

>&2 echo "compiling parallel source code (make)..."
make

>&2 echo "compiling parallel source code (make install)..."
make install
cd ..


# transfer metagenes
cp /staging/qzhang333/DOFS_MAG_genes.faa .

mkdir DOFS_MAG_gene_kofam

# run kofam
exec_annotation -o DOFS_MAG_gene_kofam/kofam.out.txt --profile profiles/ --ko-list ko_list --format detail-tsv --cpu=4 DOFS_MAG_genes.faa

# move output back to staging
tar -czf DOFS_MAG_gene_kofam.tar.gz DOFS_MAG_gene_kofam
mv DOFS_MAG_gene_kofam.tar.gz /staging/qzhang333/

# clear dir
rm *.faa
rm *.tar.gz
rm *.tar.bz2
rm ko_list