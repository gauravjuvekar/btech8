#!/bin/bash
set -x
set -e
set -o pipefail

DATA_DIR=$(realpath "$1")
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


function setup_all() {
    cd "$1"
    pipenv sync --verbose
    setup_s2v
    cd ..
}

function link_data() {
    unlink ./data || true;
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
if [ ! -d semcor3.0 ]
then
    gzip -cd semcor3.0.tar.gz | tar -x
fi
if [ ! -f glove.840B.300d.txt ]
then
    unzip glove.840B.300d.zip
fi
if [ ! -d SemEval-2015-task-13-v1.0 ]
then
    unzip semeval-2015-task-13-v1.0.zip
fi
if [ ! -d opinosis ]
then
    mkdir -p opinosis
    unzip -d opinosis OpinosisDataset1.0_0.zip
fi
cd "$THIS_DIR"

THIS_DIR=$(pwd)
cd "$DATA_DIR/cmplg-xml"
# Bad files
rm  -f 9604012.xml 9604024.xml 9605004.xml 9502033.xml 9502039.xml

for filename in ./*.xml
do
    iconv -f utf-8 -t ascii//translit < "$filename" > "$filename".ascii
done

mkdir -p gold
mkdir -p bodies
for filename in ./*.xml.ascii; do
    xmlstarlet sel -t -v '//ABSTRACT' -n $filename > ./gold/`basename -s '.xml.ascii' "$filename"`_gold.txt
    xmlstarlet sel -t -v '//BODY' -n $filename > ./bodies/`basename -s '.xml.ascii' "$filename"`_body.txt
done
cd "$THIS_DIR"


THIS_DIR=$(pwd)
cd "$DATA_DIR/opinosis"
rm -rf examples
rm -rf scripts
rm -rf OpinosisDataset1.2.pdf
rm -f topics/updates_garmin_nuvi_255W_gps.txt.data
rm -rf summaries-gold/updates_garmin_nuvi_255W_gps
mkdir gold
mv summaries-gold/**/*.gold gold
rmdir summaries-gold/*
rmdir summaries-gold
cd gold
rename -E 's/_//g' *
rename -E 's/\.([0-9])\.gold/_reference$1.txt/g' *
cd ..
cd "$THIS_DIR"


cd SIF
if [ ! -f "$DATA_DIR/sif.db" ]
then
    pipenv run python glove_to_db.py "$DATA_DIR/sif.db" "$DATA_DIR/glove.840B.300d.txt"
fi
cd ..

cd extractive
pipenv run python -c "import nltk; nltk.download('perluniprops')"
pipenv run python -c "import nltk; nltk.download('punkt')"
cd ..

cd wsd
pipenv run python -c "import nltk; nltk.download('wordnet')"
pipenv run python -c "import nltk; nltk.download('perluniprops')"
pipenv run python -c "import nltk; nltk.download('punkt')"
cd ..
