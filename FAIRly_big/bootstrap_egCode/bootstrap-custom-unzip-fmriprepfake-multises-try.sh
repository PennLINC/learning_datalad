# Modified from: TheWay (github repo)/scripts/cubic/bootstrap-custom-unzip-fmriprep-multises.sh
#       SHASUM: ee552a9 (version date: 10/20/2022)
# Modified for preparing examples for implementing `babs-unzip` in BABS.
# How to run? 
#   1. cd to where current bash script is;
#   2. run: `bash bootstrap-custom-unzip-fmriprepfake-multises-try.sh /cbica/projects/BABS/data/test_babs_multi-ses_fmriprepfake /cbica/projects/BABS/data`
#   3. before running merging, IF NEEDED (check in output RIA first!!!), you need to change 'master' to 'main' in `code/merge_outputs.sh`...

## NOTE ##
# This workflow is derived from the Datalad Handbook

## Ensure the environment is ready to bootstrap the analysis workspace
# Check that we have conda installed

DERIVATIVE_BOOTSTRAP_DIR=$1
WHERE_UNZIP_PROJECT=$2

DATALAD_VERSION=$(datalad --version)

if [ $? -gt 0 ]; then
    echo "No datalad available in your conda environment."
    echo "Try pip install datalad"
    # exit 1
fi

echo USING DATALAD VERSION ${DATALAD_VERSION}

set -e -u


## Set up the directory that will contain the necessary directories
PROJECTROOT=${WHERE_UNZIP_PROJECT}/FMRIPREPFAKE-UNZIPPED
if [[ -d ${PROJECTROOT} ]]
then
    echo ${PROJECTROOT} already exists
    # exit 1
fi

if [[ ! -w $(dirname ${PROJECTROOT}) ]]
then
    echo Unable to write to ${PROJECTROOT}\'s parent. Change permissions and retry
    # exit 1
fi

mkdir -p $PROJECTROOT

## DERIVATIVE_BOOTSTRAP_DIR will be the path to the bootstrap directory containing your derivatives

DERIVATIVE_INPUT=ria+file://${DERIVATIVE_BOOTSTRAP_DIR}"/output_ria#~data"
if [[ -z ${DERIVATIVE_BOOTSTRAP_DIR} ]]
then
    echo "Required argument is the path to the fmriprep bootstrap directory."
    echo "This directory should contain analysis/, input_ria/ and output_ria/."
    # exit 1
fi

cd ${PROJECTROOT}
# Jobs are set up to not require a shared filesystem (except for the lockfile)
# ------------------------------------------------------------------------------
# RIA-URL to a different RIA store from which the dataset will be cloned from.
# Both RIA stores will be created
input_store="ria+file://${PROJECTROOT}/input_ria"
output_store="ria+file://${PROJECTROOT}/output_ria"

# Create a source dataset with all analysis components as an analysis access
# point.
cd $PROJECTROOT
datalad create -c yoda analysis
cd analysis

# create dedicated input and output locations. Results will be pushed into the
# output sibling and the analysis will start with a clone from the input sibling.
datalad create-sibling-ria -s output "${output_store}" --new-store-ok
pushremote=$(git remote get-url --push output)
datalad create-sibling-ria -s input --storage-sibling off "${input_store}" --new-store-ok

datalad install -d . -r --source ${DERIVATIVE_INPUT} inputs/data

# amend the previous commit with a nicer commit message
git commit --amend -m 'Register input data dataset as a subdataset'

ZIPS=$(find inputs/data -name 'sub-*fmriprepfake*' | cut -d '/' -f 3 | sort)
if [ -z "${ZIPS}" ]
then
    echo "No subjects found in input data"
    # exit 1
fi

## the actual compute job specification
cat > code/participant_job.sh << "EOT"
#!/bin/bash
#$ -S /bin/bash
#$ -l h_vmem=20G
#$ -l tmpfree=50G
#$ -R y 
#$ -l h_rt=24:00:00
# Set up the correct conda environment
source ${CONDA_PREFIX}/bin/activate mydatalad
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
# OR Run it on a shared network drive
# cd /cbica/comp_space/$(basename $HOME)
# Used for the branch names and the temp dir
BRANCH="job-${JOB_ID}-${subid}-${sesid}"
mkdir ${BRANCH}
cd ${BRANCH}
# get the analysis dataset, which includes the inputs as well
# importantly, we do not clone from the lcoation that we want to push the
# results to, in order to avoid too many jobs blocking access to
# the same location and creating a throughput bottleneck
datalad clone "${dssource}" ds
# all following actions are performed in the context of the superdataset
cd ds
git remote add outputstore "$pushgitremote"
git checkout -b "${BRANCH}"
# ------------------------------------------------------------------------------
# Do the run!
html=${subid}_${sesid}.html
datalad run \
    -i code/get_files.sh \
    -i inputs/data/${subid}_${sesid}_fmriprepfake*.zip \
    --explicit \
    -o ${subid}_${sesid}*space-T1w_desc-brain_mask.nii.gz \
    -o ${html} \
    -m "unzipped ${subid}_${sesid}" \
    "bash code/get_files.sh inputs/data/${subid}_${sesid}_fmriprepfake*.zip"
# file content first -- does not need a lock, no interaction with Git
datalad push --to output-storage
# and the output branch
flock $DSLOCKFILE git push outputstore
echo TMPDIR TO DELETE
echo ${BRANCH}
datalad drop -r . --nocheck
datalad uninstall -r inputs/data
git annex dead here
cd ../..
rm -rf $BRANCH
echo SUCCESS
# job handler should clean up workspace
EOT

chmod +x code/participant_job.sh

## the actual compute job specification
echo writing script to file...
cat > code/get_files.sh << "EOT"
#!/bin/bash
set -e -u -x
ZIP_FILE=$1
subid=$(basename $ZIP_FILE | cut -d '_' -f 1)
sesid=$(basename $ZIP_FILE | cut -d '_' -f 2)

# unzip outputs
unzip -n $ZIP_FILE 'fmriprepfake/*' -d .
desired_files=fmriprepfake/${subid}/${sesid}/func/*space-T1w_desc-brain_mask.nii.gz
for desired_file in $desired_files; do
# check if the desired file exists
if [ -f ${desired_file} ];
then
    # copy only the file we need out of fmriprepfake
    cp ${desired_file} .
fi
done
# remove unzip dir
rm -rf fmriprepfake

EOT

chmod +x code/get_files.sh

mkdir logs
echo .SGE_datalad_lock >> .gitignore
echo logs >> .gitignore

datalad save -m "Participant compute job implementation"

# Add a script for merging outputs
MERGE_POSTSCRIPT=https://raw.githubusercontent.com/PennLINC/TheWay/main/scripts/cubic/merge_outputs_postscript.sh
cat > code/merge_outputs.sh << "EOT"
#!/bin/bash
set -e -u -x
EOT
echo "outputsource=${output_store}#$(datalad -f '{infos[dataset][id]}' wtf -S dataset)" \
    >> code/merge_outputs.sh
echo "cd ${PROJECTROOT}" >> code/merge_outputs.sh
wget -qO- ${MERGE_POSTSCRIPT} >> code/merge_outputs.sh

################################################################################
# SGE SETUP START - remove or adjust to your needs
################################################################################
env_flags="-v DSLOCKFILE=${PWD}/.SGE_datalad_lock"

echo '#!/bin/bash' > code/qsub_calls.sh
dssource="${input_store}#$(datalad -f '{infos[dataset][id]}' wtf -S dataset)"
pushgitremote=$(git remote get-url --push output)
eo_args="-e ${PWD}/logs -o ${PWD}/logs"

for zip in ${ZIPS}; do
    subject=`echo ${zip} | cut -d '_' -f 1` 
    session=`echo ${zip} | cut -d '_' -f 2` 
    echo "qsub -cwd ${env_flags} -N UNZIP${subject}_${session} ${eo_args} \
    ${PWD}/code/participant_job.sh \
    ${dssource} ${pushgitremote} ${subject} ${session}" >> code/qsub_calls.sh
done
datalad save -m "SGE submission setup" code/ .gitignore

################################################################################
# SGE SETUP END
################################################################################

# cleanup - we have generated the job definitions, we do not need to keep a
# massive input dataset around. Having it around wastes resources and makes many
# git operations needlessly slow
datalad uninstall -r --nocheck inputs/data


# make sure the fully configured output dataset is available from the designated
# store for initial cloning and pushing the results.
datalad push --to input
datalad push --to output

# Add an alias to the data in the RIA store
RIA_DIR=$(find $PROJECTROOT/output_ria/???/ -maxdepth 1 -type d | sort | tail -n 1)
mkdir -p ${PROJECTROOT}/output_ria/alias
ln -s ${RIA_DIR} ${PROJECTROOT}/output_ria/alias/data

# if we get here, we are happy
echo SUCCESS
