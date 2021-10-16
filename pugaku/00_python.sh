#!/bin/bash
#SBATCH -p comp
#SBATCH --time=24:00:00
#SBATCH --mail-type="ALL"
#SBATCH -J "ratf_env"
#SBATCH --comment="tensorflow2.2.0 setup with spack"
##SBATCH --mail-user="hogehoge@fugafuga.slack.com"

# enveronments
export ENV_NAME=test
export TMPDIR=/tmp

# install with spack
PACKAGE_NAMES=( \
    "py-numpy" \
    "py-pip" \
    "py-h5py" \
    "py-matplotlib" \
    "py-tornado" \
    "py-docopt" \
    "py-pylint" \
    "py-pytest" \
    "py-pytest-cov" \
    "py-progress" \
    "py-prettytable" \
    "py-mypy" \
    "py-psutil" \
    "py-plotly" \
    "py-crcmod" \
    "py-pyyaml" \
)

# load private spack
. ${HOME}/spack/share/spack/setup-env.sh

# create spack env & activate
spack env remove -y ${ENV_NAME}
spack env create ${ENV_NAME}

# spack add/install in spack env
spack env activate -p ${ENV_NAME}
spack add python +tkinter
for PACKAGE_NAME in "${PACKAGE_NAMES[@]}"; do
    spack add "${PACKAGE_NAME}"
done
spack add py-tensorflow -cuda -nccl +mpi
spack add py-torch -cuda -nccl -cudnn
date
echo "** start spack install"
spack install
echo "** end spack install"
date
echo "** result"
which python
python --version
python -c "import tensorflow"
python -c "import torch"
pip list

#####
# EoF
#####