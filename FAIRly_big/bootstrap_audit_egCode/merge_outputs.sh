#!/bin/bash
set -e -u -x
outputsource=ria+file:///cbica/projects/RBC/chenying_practice/fmriprep-multises-audit/output_ria#d7d43530-93a3-4849-83ee-af7b3500f8d5
cd /cbica/projects/RBC/chenying_practice/fmriprep-multises-audit
datalad clone ${outputsource} merge_ds
cd merge_ds
NBRANCHES=$(git branch -a | grep job- | sort | wc -l)
echo "Found $NBRANCHES branches to merge"

gitref=$(git show-ref master | cut -d ' ' -f1 | head -n 1)

# query all branches for the most recent commit and check if it is identical.
# Write all branch identifiers for jobs without outputs into a file.
for i in $(git branch -a | grep job- | sort); do [ x"$(git show-ref $i \
  | cut -d ' ' -f1)" = x"${gitref}" ] && \
  echo $i; done | tee code/noresults.txt | wc -l


for i in $(git branch -a | grep job- | sort); \
  do [ x"$(git show-ref $i  \
     | cut -d ' ' -f1)" != x"${gitref}" ] && \
     echo $i; \
done | tee code/has_results.txt

mkdir -p code/merge_batches
num_branches=$(wc -l < code/has_results.txt)
CHUNKSIZE=5000

set +e
num_chunks=$(expr ${num_branches} / ${CHUNKSIZE})
[[ $num_chunks == 0 ]] && num_chunks=1
set -e -x

for chunknum in $(seq 1 $num_chunks)
do
    startnum=$(expr $(expr ${chunknum} - 1) \* ${CHUNKSIZE} + 1)
    endnum=$(expr ${chunknum} \* ${CHUNKSIZE})
    batch_file=code/merge_branches_$(printf %04d ${chunknum}).txt
    [[ ${num_branches} -lt ${endnum} ]] && endnum=${num_branches}
    branches=$(sed -n "${startnum},${endnum}p;$(expr ${endnum} + 1)q" code/has_results.txt)
    echo ${branches} > ${batch_file}
    git merge -m "fmriprep results batch ${chunknum}/${num_chunks}" $(cat ${batch_file})

done

# Push the merge back
git push

# Get the file availability info
git annex fsck --fast -f output-storage

# This should not print anything
set +u
MISSING=$(git annex find --not --in output-storage)

if [[ ! -z "$MISSING" ]]
then
    echo Unable to find data for $MISSING
    exit 1
fi

# stop tracking this branch
git annex dead here
datalad push --data nothing
echo SUCCESS

