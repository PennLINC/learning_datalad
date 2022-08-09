#!/bin/bash
#$ -S /bin/bash
#$ -l h_vmem=5G
#$ -l s_vmem=3.5G
# Set up the correct conda environment
source ${CONDA_PREFIX}/bin/activate base
echo I\'m in $PWD using `which python`

# fail whenever something is fishy, use -x to get verbose logfiles
set -e -u -x

# Set up the remotes and get the subject id from the call
dssource="$1"
pushgitremote="$2"
subid="$3"
sesid="$4"

# change into the cluster-assigned temp directory. Not done by default in SGE
cd ${CBICA_TMPDIR}

# Used for the branch names and the temp dir
BRANCH="job-${JOB_ID}-${subid}-${sesid}"
mkdir ${BRANCH}
cd ${BRANCH}
datalad clone "${dssource}" ds
cd ds
git remote add outputstore "$pushgitremote"
git checkout -b "${BRANCH}"

# ------------------------------------------------------------------------------
# Do the run!
BIDS_DIR=${PWD}/inputs/data/inputs/data
ZIPS_DIR=${PWD}/inputs/data
ERROR_DIR=${PWD}/inputs/fmriprep_logs
CSV_DIR=csvs
mkdir ${CSV_DIR}
output_file=${CSV_DIR}/${subid}_${sesid}_fmriprep_audit.csv

datalad get -n inputs/data

INPUT_ZIP=$(ls inputs/data/${subid}_${sesid}_fmriprep*.zip | cut -d '@' -f 1 || true)
if [ ! -z "${INPUT_ZIP}" ]; then
    INPUT_ZIP="-i ${INPUT_ZIP}"
fi

echo DATALAD RUN INPUT
echo ${INPUT_ZIP}

datalad run \
    -i code/bootstrap-fmriprep-multises-audit.py \
    ${INPUT_ZIP} \
    -i inputs/data/inputs/data/${subid} \
    -i inputs/fmriprep_logs/*${subid}*${sesid}* \
    --explicit \
    -o ${output_file} \
    -m "fmriprep-audit ${subid} ${sesid}" \
    "python code/bootstrap-fmriprep-multises-audit.py ${subid}_${sesid} ${BIDS_DIR} ${ZIPS_DIR} ${ERROR_DIR} ${output_file}"

# file content first -- does not need a lock, no interaction with Git
datalad push --to output-storage
# and the output branch
flock $DSLOCKFILE git push outputstore

echo TMPDIR TO DELETE
echo ${BRANCH}

datalad uninstall -r --nocheck --if-dirty ignore inputs/data
datalad drop -r . --nocheck
git annex dead here
cd ../..
rm -rf $BRANCH

echo SUCCESS
# job handler should clean up workspace
