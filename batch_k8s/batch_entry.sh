#!/bin/bash

# definitions
CODE_ROOT="/ceph/gammanet"
NB_SUBDIR="batch"
DATA_SUBDIR="data"
RESULTS_SUBDIR="results"
DATA_FILE="ACDC_split.tar.bz2"

# inputs
if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <experiment code> [data file path]" >&2
  exit 1
fi
export EXP_CODE="$1"
if [ "$#" == 2 ]; then
  DATA_FILE=$2
fi

# init code repo
cd /root
git clone https://github.com/jasonliam/gammanet-pytorch
cd /root/gammanet-pytorch
git submodule update --init
mv pytorch-unet pytorch_unet

# check code root
if [ ! -d "${CODE_ROOT}" ]; then
  echo "Code root directory does not exist" >&2
  exit 1
fi

# check job notebook
if [ ! -f "${CODE_ROOT}/${NB_SUBDIR}/${EXP_CODE}.ipynb" ]; then
  echo "Job notebook does not exist" >&2
  exit 1
fi

# check data file 
if [ ! -f "${CODE_ROOT}/${DATA_SUBDIR}/${DATA_FILE}" ]; then
  echo "Data file does not exist" >&2
  exit 1
fi

# copy and expand training data
cp "${CODE_ROOT}/${DATA_SUBDIR}/${DATA_FILE}" .
apt-get update && apt-get install pbzip2
tar -Ipbzip2 -xf "${DATA_FILE}"

# copy notebook for batch job
cp "${CODE_ROOT}/${NB_SUBDIR}/${EXP_CODE}.ipynb" .

# convert notebook and launch batch job
jupyter nbconvert --to python "${EXP_CODE}.ipynb"
ipython "${EXP_CODE}.py"
rm "${EXP_CODE}.py"

# package experiment results and save
tar -czf "$EXP_CODE.tar.gz" "$EXP_CODE/"
cp "$EXP_CODE.tar.gz" "${CODE_ROOT}/${RESULTS_SUBDIR}/"


