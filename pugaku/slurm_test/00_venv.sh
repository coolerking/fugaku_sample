#!/bin/bash
#SBATCH -p ppsq
#SBATCH --time=24:00:00
#SBATCH --gpus=1
#SBATCH --gpus-per-node=1
#SBATCH --gpus-per-task=1
#SBATCH --mail-type="ALL"
#SBATCH --mail-user="hogehoge@fugafuga.slack.com"
#SBATCH -J "create_venv"
#SBATCH --comment="gpu_node sample create venv"

###
# 富岳GPUノード用TensorFlow 2.5.0/PyTorch1.8.1環境をvenvで構築
###
export ENV_NAME=gpu_sample
export PATH=${PATH}:/usr/local/cuda-11.2/bin
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-11.2/lib64
mkdir -p ${HOME}/.local
mkdir -p ${HOME}/.local/avx512
cd ${HOME}/.local/avx512
python3 -m venv ${ENV_NAME}
source ${ENV_NAME}/bin/activate
pip3 install pip --upgrade
pip3 install tensorflow-gpu==2.5.0
pip3 install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 -f https://download.pytorch.org/whl/lts/1.8/torch_lts.html
# etc
pip3 list
#####
# EoF
#####