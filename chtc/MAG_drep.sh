#!/bin/bash

# unpack pipeline 
tar -xzf hmmer-3.4.tar.gz
tar -xzf Prodigal-2.6.3.tar.gz
tar -xzf mash-Linux64-v2.3.tar.gz
tar -xzf MUMmer-3.23.tar.gz
tar -xzf FastANI-1.34.tar.gz
tar -xzf ANIcalculator_v1.tar.gz
tar -xzf python-3.10.12.tar.gz
tar -xzf python-3.10.12-packages.tar.gz

tar -xzf gsl-2.8.tar.gz

unzip pplacer-linux-v1.1.alpha19.zip

# set path
export PATH=$(pwd)/hmmer-3.4/bin:$PATH
export PATH=$(pwd)/Prodigal-2.6.3:$PATH
export PATH=$(pwd)/mash-Linux64-v2.3:$PATH
export PATH=$(pwd)/MUMmer-3.23:$PATH
export PATH=$(pwd)/FastANI-1.34/bin:$PATH
export PATH=$(pwd)/ANIcalculator_v1:$PATH
export PATH=$(pwd)/pplacer-Linux-v1.1.alpha19:$PATH
export PATH=$(pwd)/python-3.10.12/bin:$PATH
export PATH=$(pwd)/python-3.10.12-packages/bin:$PATH
export PYTHONPATH=$(pwd)/python-3.10.12-packages

export LD_LIBRARY_PATH=$(pwd)/gsl-2.8/lib:$LD_LIBRARY_PATH

# replace path in drep binary 
sed -i "s:/var/lib/condor/execute/slot1/dir_243108:${PWD}:g" python-3.10.12-packages/bin/checkm
sed -i "s:/var/lib/condor/execute/slot1/dir_243108:${PWD}:g" python-3.10.12-packages/bin/dRep

# check all modules
>&2 echo -e 'Checking installed python module and their version:'
>&2 python3 -m pip freeze
>&2 echo -e '\n'

# transfer MAG files
cp /staging/qzhang333/DOFS_MAG_HQ.tar.gz .
tar -zxf DOFS_MAG_HQ.tar.gz

# run drep
mkdir MAG_drep_out

dRep dereplicate MAG_drep_out -p 8 -pa 0.9 -sa 0.99 --ignoreGenomeQuality -g DOFS_MAG_HQ/*.fa

# move output to staging/qzhang333
tar -czf MAG_drep_out.tar.gz MAG_drep_out
mv MAG_drep_out.tar.gz /staging/qzhang333

# clear other data
rm *.tar.gz