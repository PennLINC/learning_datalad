#!/bin/bash
set -e -u -x

subid="$1"
sesid="$2"

# Create a filter file that only allows this session
filterfile=${PWD}/${sesid}_filter.json
echo "{" > ${filterfile}
echo "'fmap': {'datatype': 'fmap'}," >> ${filterfile}
echo "'bold': {'datatype': 'func', 'session': '$sesid', 'suffix': 'bold'}," >> ${filterfile}
echo "'sbref': {'datatype': 'func', 'session': '$sesid', 'suffix': 'sbref'}," >> ${filterfile}
echo "'flair': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'FLAIR'}," >> ${filterfile}
echo "'t2w': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'T2w'}," >> ${filterfile}
echo "'t1w': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'T1w'}," >> ${filterfile}
echo "'roi': {'datatype': 'anat', 'session': '$sesid', 'suffix': 'roi'}" >> ${filterfile}
echo "}" >> ${filterfile}

# remove ses and get valid json
sed -i "s/'/\"/g" ${filterfile}
sed -i "s/ses-//g" ${filterfile}

mkdir -p ${PWD}/.git/tmp/wdir
singularity run --cleanenv -B ${PWD} \
    pennlinc-containers/.datalad/environments/fmriprep-20-2-3/image \
    inputs/data \
    prep \
    participant \
    -w ${PWD}/.git/tmp/wkdir \
    --n_cpus 1 \
    --stop-on-first-crash \
    --fs-license-file code/license.txt \
    --skip-bids-validation \
    --bids-filter-file "${filterfile}" \
    --output-spaces MNI152NLin6Asym:res-2 \
    --participant-label "$subid" \
    --force-bbr \
    --cifti-output 91k -v -v

cd prep
7z a ../${subid}_${sesid}_fmriprep-20.2.3.zip fmriprep
7z a ../${subid}_${sesid}_freesurfer-20.2.3.zip freesurfer
rm -rf prep .git/tmp/wkdir
rm ${filterfile}

