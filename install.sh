#!/bin/bash

DATA_DIR="$1"

function setup_s2v() {
    cd sent2vec/src
    pipenv run python setup.py build
    pipenv run python setup.py install
    cd ../..
}

git submodule update --init --recursive

sudo apt-get install -y python3-pip cython3 python3-dev  python-pip cython python-dev build-essential
pip3 install pipenv

cd wsd
pipenv sync --verbose
setup_s2v
cd ..

cd extractive
pipenv sync --verbose
setup_s2v
cd ..
