#!/bin/bash
set -x

DATA_DIR="$1"


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
    xmlstarlet
pip3 install pipenv

setup_all ./wsd
cd wsd
link_data "$DATA_DIR"
cd ..


setup_all ./extractive
cd extractive
link_data "$DATA_DIR"
cd ..

THIS_DIR=$(pwd)
cd "$DATA_DIR"
md5sum -c md5sums.txt
cd "$THIS_DIR"

THIS_DIR=$(pwd)
cd "$DATA_DIR"
gzip -cd cmplg-xml.tar.gz | tar -x
gzip -cd GoogleNews-vectors-negative300.bin.gz > GoogleNews-vectors-negative300.bin
gzip -cd semcor3.0.tar.gz | tar -x
unzip glove.840B.300d.zip
unzip semeval-2015_task13_trial.zip
cd "$THIS_DIR"

THIS_DIR=$(pwd)
cd "$DATA_DIR/cmplg-xml"
rm 9604012.xml 9604024.xml 9605004.xml
cd "$THIS_DIR"

