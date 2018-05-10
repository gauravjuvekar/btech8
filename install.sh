#!/bin/bash

DATA_DIR="$1"

git submodule update --init --recursive

sudo apt-get install -y python3-pip cython3 python3-dev  python-pip cython python-dev
pip3 install pipenv

cd wsd
pipenv sync

cd ..

cd extractive
pipenv sync


