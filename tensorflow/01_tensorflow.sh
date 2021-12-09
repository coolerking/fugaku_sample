#!/bin/bash
#PJM --rsc-list "node=1"
#PJM --rsc-list "rscunit=rscunit_ft01"
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "elapse=72:00:00"
#PJM --mpi "proc=1"
#PJM -m b,e,s
#PJM --mail-list "hogehoge@fugafuga.slack.com"
#PJM -S

# (C) Copyright by Tasuku Hori, 2021.

# Build tensorflow 2.2.0 with tkinter which can work on fugaku computer-node

# 1. login to a login-node with ssh or vpn
# 2. submit job with this and run on fugaku computer-node 
#    loginXXX $ pjsub 01_tensorflow.sh
#    (about 7 hours 30 minitus)
#    installed from ${HOME}/.tmp to ${HOME}/.local/aarch64
# 3. login to a computer-node with conversation job
# 4. activate venv "tensorflow"
#    compXXX $ source ${HOME}/.local/aarch64/venv/tensorflow/bin/activate
# 5. test python
#    (tensorflow) compXXX $ python -c "import tkinter"
#    (tensorflow) compXXX $ python -c "import tensorflow"
#    if OK, both commands will end with no messages

echo "** start"
echo "** start" 1>&2
date
date 1>&2
CURRENT_PATH=`pwd`

# venv name
export ENV_NAME="tensorflow"
echo "** ENV_NAME=${ENV_NAME}"
echo "** ENV_NAME=${ENV_NAME}" 1>&2


# target directory
mkdir ${HOME}/.local
cd ${HOME}/.local
rm -rf aarch64
mkdir aarch64
mkdir -p aarch64/lib
mkdir -p aarch64/lib64
mkdir -p aarch64/bin
mkdir -p aarch64/venv
mkdir -p aarch64/share
mkdir -p aarch64/man
export LOCAL_BASE=${HOME}/.local/aarch64
echo "** LOCAL_BASE=${LOCAL_BASE}"
echo "** LOCAL_BASE=${LOCAL_BASE}" 1>&2

# temporary directory
cd ${HOME}
rm -rf .tmp
mkdir .tmp
export TMPDIR=${HOME}/.tmp
echo "** TMPDIR=${TMPDIR}"
echo "** TMPDIR=${TMPDIR}" 1>&2

# git checkout
echo "** git checkout tensorflow"
echo "** git checkout tensorflow" 1>&2
cd ${TMPDIR}
git clone https://github.com/fujitsu/tensorflow.git
cd tensorflow
git checkout -b fujitsu_v2.2.0_for_a64fx origin/fujitsu_v2.2.0_for_a64fx
cp ./fcc_build_script/env.src ./fcc_build_script/env.src.org
echo "** copy env.src_fugaku"
echo "** copy env.src_fugaku" 1>&2
cp ${CURRENT_PATH}/env.src_fugaku ./fcc_build_script/env.src
cat ./fcc_build_script/env.src | grep PREFIX
cat ./fcc_build_script/env.src | grep PREFIX 1>&2
cat ./fcc_build_script/env.src | grep TCSDS_PATH
cat ./fcc_build_script/env.src | grep TCSDS_PATH 1>&2
cat ./fcc_build_script/env.src | grep VENV_PATH
cat ./fcc_build_script/env.src | grep VENV_PATH 1>&2


# clean/download
cd ${TMPDIR}/tensorflow/fcc_build_script
pwd
pwd 1>&2
export TARGETS=( \
        "01_python_build.sh" \
        "02_bazel_build.sh" \
        "03_oneDNN_build.sh" \
        "04_make_venv.sh" \
        "05-0_set_tf_src.sh" \
        "05-1_build_batchedblas.sh" \
        "05_tf_build.sh" \
        "06_tf_install.sh" \
        "07_horovod_install.sh" \
        )

for TARGET in "${TARGETS[@]}"; do
        echo "** ${TARGET} clean start"
        echo "** ${TARGET} clean start" 1>&2
        date
        date 1>&2
        ./${TARGET} clean
        RETCODE=$@
        date
        date 1>&2
        echo "** ${TARGET} clean end:${RETCODE}"
        echo "** ${TARGET} clean end:${RETCODE}" 1>&2
done
for TARGET in "${TARGETS[@]}"; do
        echo "** ${TARGET} download start"
        echo "** ${TARGET} download start" 1>&2
        date
        date 1>&2
        ./${TARGET} download
        date
        date 1>&2
        echo "** ${TARGET} download end:${RETCODE}"
        echo "** ${TARGET} download end:${RETCODE}" 1>&2
done
# tcl/tk
echo "** tcl/tk start"
echo "** tcl/tk start" 1>&2
date
date 1>&2
cd ${TMPDIR}
echo "** get tcl source"
echo "** get tcl source" 2>&1
wget https://prdownloads.sourceforge.net/tcl/tcl8.6.12-src.tar.gz
tar xvfz ./tcl8.6.12-src.tar.gz
echo "** get tk source"
echo "** get tk source" 2>&1
wget https://prdownloads.sourceforge.net/tcl/tk8.6.12-src.tar.gz
tar xvfz ./tk8.6.12-src.tar.gz
rm -rf ./tk8.6.12-src.tar.gz ./tcl8.6.12-src.tar.gz
echo "** build tcl"
echo "** build tcl" 2>&1
cd ${TMPDIR}/tcl8.6.12/unix
mkdir aarch64
cd aarch64
${TMPDIR}/tcl8.6.12/unix/configure --prefix=${LOCAL_BASE}
make
make install
echo "** build tk"
echo "** build tk" 2>&1
cd ${TMPDIR}/tk8.6.12/unix
mkdir aarch64
cd aarch64
${TMPDIR}/tk8.6.12/unix/configure --with-tcl=${TMPDIR}/tcl8.6.12/unix/aarch64 --prefix=${LOCAL_BASE}
make
make install
echo "** tcl/tk end"
echo "** tcl/tk end" 1>&2

# build python
echo "** python+tkinter start"
echo "** python+tkinter start" 1>&2
date
date 1>&2
export LD_LIBRARY_PATH_ORG=${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${LOCAL_BASE}/lib
cd ${TMPDIR}/tensorflow/fcc_build_script
pwd
pwd 1>&2
TARGET=01_python_build.sh
echo "** ${TARGET} start"
echo "** ${TARGET} start" 1>&2
./${TARGET}
RETCODE=$@
echo "** ${TARGET} end: ${RETCODE}"
echo "** ${TARGET} end: ${RETCODE}" 1>&2
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH_ORG}
echo "** python+tkinter end"
echo "** python+tkinter end" 1>&2

# build rest scripts
cd ${TMPDIR}/tensorflow/fcc_build_script
pwd
pwd 1>&2
export TARGETS=( \
        "02_bazel_build.sh" \
        "03_oneDNN_build.sh" \
        "04_make_venv.sh" \
        "05-0_set_tf_src.sh" \
        "05-1_build_batchedblas.sh" \
        "05_tf_build.sh" \
        "06_tf_install.sh" \
        "07_horovod_install.sh" \
        )
for TARGET in "${TARGETS[@]}"; do
        echo "** ${TARGET} start"
        echo "** ${TARGET} start" 1>&2
        date
        date 1>&2
        ./${TARGET}
        date
        date 1>&2
        echo "** ${TARGET} end:${RETCODE}"
        echo "** ${TARGET} end:${RETCODE}" 1>&2
done
echo "** end ${RETCODE}"
echo "** end ${RETCODE}" 1>&2
###
# EOF
###
date
date 1>&2
exit ${RETCODE}
