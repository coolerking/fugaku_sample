#!/bin/bash
#PJM --rsc-list "node=4"
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "elapse=72:00:00"
#PJM --mpi "max-proc-per-node=4"
#PJM -m b,e,s
#PJM -S
##PJM --mail-list "hogehoge@fugafuga.slack.com"

export OMP_NUM_THREADS=12

module purge
module load lang/tcsds-1.2.31

module load Python3-CN/3.6.8-Mar
export FLIB_CNTL_BARRIER_ERR=FALSE
export LD_PRELOAD=/usr/lib/FJSVtcs/ple/lib64/libpmix.so
export TMPDIR=${HOME}/.tmp

export PATH=${HOME}/.local/aarch64/bin:${PATH}
export LD_LIBRARY_PATH=/lib64:${HOME}/.local/aarch64/lib:${LD_LIBRARY_PATH}

export OMP_NUM_THREADS=12
llio_transfer ./C_Pi

echo "** start C_Pi **"
date
mpiexec -n 16 ./C_Pi
date
echo "** end   C_Pi **"

##
# eof
##
