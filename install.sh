#!/bin/bash
set -x

DATA_DIR=$(realpath "$1")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function setup_all() {
    cd "$1"
    pipenv sync --verbose
    setup_s2v
    cd ..
}

function link_data() {
    ln -s "$1" data
}

function setup_s2v() {
    cd sent2vec/src
    pipenv run python setup.py build
    pipenv run python setup.py install
    cd ../..
}

git submodule update --init --recursive

sudo apt-get install -y \
    python3-pip cython3 python3-dev  \
    python-pip cython python-dev \
    build-essential \
    xmlstarlet \
    coreutils
pip3 install pipenv

setup_all ./wsd
cd wsd
link_data "$DATA_DIR"
cd ..


setup_all ./extractive
cd extractive
link_data "$DATA_DIR"
cd ..

cd SIF
link_data "$DATA_DIR"
pipenv sync --verbose
cd ..


THIS_DIR=$(pwd)
cd "$DATA_DIR"
md5sum -c "$SCRIPT_DIR/md5sums.txt"
cd "$THIS_DIR"

THIS_DIR=$(pwd)
cd "$DATA_DIR"
if [ ! -d cmplg-xml ]
then
    gzip -cd cmplg-xml.tar.gz | tar -x
fi
if [ ! -f GoogleNews-vectors-negative300.bin ]
then
    gzip -cd GoogleNews-vectors-negative300.bin.gz > GoogleNews-vectors-negative300.bin
fi
gzip -cd semcor3.0.tar.gz | tar -x
if [ ! -f glove.840B.300d.txt ]
then
    unzip glove.840B.300d.zip
fi
unzip semeval-2015-task-13-v1.0.zip
mkdir opinosis
unzip -d opinosis OpinosisDataset1.0_0.zip
rm -rf opinosis/examples
rm -rf opinosis/scripts
rm -rf opinosis/OpinosisDataset1.2.pdf
rm opinosis/topics/updates_garmin_nuvi_255W_gps.txt.data
rm -rf opinosis/summaries-gold/updates_garmin_nuvi_255W_gps

cd "$THIS_DIR"

THIS_DIR=$(pwd)
cd "$DATA_DIR/cmplg-xml"
rm 9604012.xml 9604024.xml 9605004.xml
cd "$THIS_DIR"

cd SIF
if [ ! -f "$DATA_DIR/sif.db" ]
then
    pipenv run python glove_to_db.py "$DATA_DIR/sif.db" "$DATA_DIR/glove.840B.300d.txt"
fi
cd ..


