#!/bin/bash
#SBATCH -p comp
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH -J test_th_multi
#SBATCH -o stdout.%J
#SBATCH -e stderr.%J

echo "*******************"
# ジョブ実行に使用されるホストとプロセス数のリスト
echo "*** job cpus per node: ${SLURM_JOB_CPUS_PER_NODE}"
# ジョブID
echo "*** job id: ${SLURM_JOB_ID}"
# sbatch -J で指定したジョブ名。ジョブ名を指定していない場合は、実際に指定されたコマンド列が格納される
echo "*** job name: ${SLURM_JOB_NAME}"
# ジョブが実行されるホスト名のリスト
echo "*** comp node list: ${SLURM_JOB_NODELIST}"
# sbatch –n(または ––ntasks)で指定したプロセス数
echo "*** process count: ${SLURM_NTASKS}"
# ジョブが投入されたカレントディレクトリ
echo "*** current directory ${SLURM_SUBMIT_DIR}" 	
echo "*******************"

export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK}

# set target executable
export TARGET=hostname


echo "** start ${TARGET}"
date
${TARGET}
date
echo "** enf   ${TARGET}"

RETCODE=$?
exit ${RETCODE}