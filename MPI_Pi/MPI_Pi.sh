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

llio_transfer ./MPI_Pi

echo "** start MPI_Pi **"
date
mpiexec -n 16 ./MPI_Pi
date
echo "** end   MPI_Pi **"

##
# eof
##
