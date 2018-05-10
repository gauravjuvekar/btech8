#!/bin/bash

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


