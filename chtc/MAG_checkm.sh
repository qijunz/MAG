#!/bin/bash

# unpack pipeline 
tar -xzf hmmer-3.4.tar.gz
tar -xzf Prodigal-2.6.3.tar.gz
tar -xzf python-3.10.12.tar.gz
tar -xzf python-3.10.12-packages.tar.gz

unzip pplacer-linux-v1.1.alpha19.zip

# set path
export PATH=$(pwd)/hmmer-3.4/bin:$PATH
export PATH=$(pwd)/Prodigal-2.6.3:$PATH
export PATH=$(pwd)/pplacer-Linux-v1.1.alpha19:$PATH
export PATH=$(pwd)/python-3.10.12/bin:$PATH
export PATH=$(pwd)/python-3.10.12-packages/bin:$PATH
export PYTHONPATH=$(pwd)/python-3.10.12-packages

# replace path in checkm binary 
sed -i "s:/var/lib/condor/execute/slot1/dir_243108:${PWD}:g" python-3.10.12-packages/bin/checkm

# check all modules
>&2 echo -e 'Checking installed python module and their version:'
>&2 python3 -m pip freeze
>&2 echo -e '\n'

# unpack checkm database
tar -xzf checkm_data_2015_01_16.tar.gz

# setRoot for checkm database
checkm data setRoot checkm_data_2015_01_16

# transfer MAG files
cp /staging/qzhang333/DOFS_MAG.tar.gz .
tar -zxf DOFS_MAG.tar.gz

# run checkm
checkm lineage_wf -t 4 -x fa DOFS_MAG/ MAG_checkm_out/

# move output to staging/qzhang333
tar -czf MAG_checkm_out.tar.gz MAG_checkm_out
mv MAG_checkm_out.tar.gz /staging/qzhang333/DOdiet_out

# clear other data
rm *.tar.gz