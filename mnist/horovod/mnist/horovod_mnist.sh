#!/bin/bash
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "elapse=72:00:00"
#PJM --rsc-list "node=4"
#PJM --mpi "proc=4"
#PJM -m b,e,s
#PJM -S
##PJM --mail-list "hogehoge@fugafuga.slack.com"

## --mpi "proc=n"     ：MPIのプロセス数の指定
## --rsc-list "node=2"：使用するノード数を指定

## 参考：https://www.hucc.hokudai.ac.jp/man/supercomputer/detail/job_script/

# ターゲットコード
export PY_SOURCE="./horovod_mnist.py"
# 指定ファイルをキャッシュにあげる
llio_transfer ${PY_SOURCE}

# 1プロセス当たりが使用するスレッド数の指定
export OMP_NUM_THREADS=12
# stdout/err 書き込みがない場合ファイルを作成しない
export FLIB_CNTL_BARRIER_ERR=FALSE

export LD_PRELOAD=/usr/lib/FJSVtcs/ple/lib64/libpmix.so

# テンポラリディレクトリ指定
export TMPDIR=${HOME}/.tmp

# fugaku 側が用意したPython/TensorFlow/horovodを使用
export PATH=/home/apps/oss/TensorFlow-2.2.0/bin:$PATH
export LD_LIBRARY_PATH=/home/apps/oss/TensorFlow-2.2.0/lib:$LD_LIBRARY_PATH

# 環境がfugaku 側が用意したPython/TensorFlow/horovod用になっているかの確認
which python3
pip3 list

echo "** start ${PY_SOURCE} **"
date
# 並列処理実行
# ** 注意 2021/10/13 **
# horovod側が提供するラッパを使った実行の場合 horovodrun -np ${PJM_MPI_PROC} python3 ${PY_SOURCE}, end with error:
# [mpi::opal-util::unknown-option] mpirun: Error: unknown option "--allow-run-as-root"
mpiexec -n ${PJM_MPI_PROC}  python3 ${PY_SOURCE}
date
echo "** end   ${PY_SOURCE} **"

#####
# EoF
#####