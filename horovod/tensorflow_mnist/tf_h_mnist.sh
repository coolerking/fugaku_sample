#!/bin/bash
#PJM --rsc-list "node=4"
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "elapse=72:00:00"
#PJM --mpi "max-proc-per-node=4"
#PJM -m b,e,s
#PJM -S
##PJM --mail-list "hogehoge@fugafuga.slack.com"

export PY_SOURCE="./tensorflow2_keras_mnist.py"
llio_transfer ${PY_SOURCE}

export OMP_NUM_THREADS=12
export FLIB_CNTL_BARRIER_ERR=FALSE
export LD_PRELOAD=/usr/lib/FJSVtcs/ple/lib64/libpmix.so
export TMPDIR=${HOME}/.tmp

export PATH=/home/apps/oss/TensorFlow2.2.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/TensorFlow2.2.0/lib:$LD_LIBRARY_PATH

pip3 list

echo "** start ${PY_SOURCE} **"
date
horovodrun -np 4 python3 ${PY_SOURCE}
date
echo "** end   ${PY_SOURCE} **"

##
# eof
##
