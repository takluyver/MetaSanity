#!/bin/bash
set -e

# Detect conda environment
CONDA=`which conda`
CONDA_DIRNAME=`dirname $CONDA`
MINICONDA=`dirname $CONDA_DIRNAME`
SOURCE=$MINICONDA/etc/profile.d/conda.sh
[ ! -f $SOURCE ] && (echo "Unable to locate source directory" && exit 1)

# Create conda env with most dependencies present and activate
conda env create -f environment.yml
source $SOURCE
conda activate MetaSanity

# Create build environment
mkdir -p build
# Download remaining data and move to build
python ./download-data.py
mv databases build/
# Link checkm data
checkm data setRoot build/databases/checkm
# Link GTDB-Tk data
echo export GTDBTK_DATA_PATH="$(pwd)"/build/databases/gtdbtk/release202 >> ~/.bashrc

# Prokka setup
conda install -y -c conda-forge -c bioconda prokka

# MetaSanity run script setup
python ./install.py -s download_metasanity,config_pull -t SourceCode -o build
sed -i "s/MetaSanity\/build\///" build/MetaSanity.py
# MetaSanity build
python setup.py build_ext --inplace
# Additional needed files
cp VERSIONS.json build/
