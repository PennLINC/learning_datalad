#!/bin/bash
set -e -u -x
outputsource=ria+file:///cbica/projects/RBC/chenying_practice/fmriprep-multises/output_ria#f308fcb6-5b36-47d0-8a8a-07271486558a
cd /cbica/projects/RBC/chenying_practice/fmriprep-multises

datalad clone ${outputsource} merge_ds
cd merge_ds
NBRANCHES=$(git branch -a | grep job- | sort | wc -l)
echo "Found $NBRANCHES branches to merge"

gitref=$(git show-ref master | cut -d ' ' -f1 | head -n 1)
# Chenying: ^^^ should be main instead of master!! 
# Matt: it depends. Git probably hasn't changed to main, only github. Do: check the git track branch name by a command to figure out whether its main or master
# TODO: check which give non-empty results, `main`, or `master`
# What does it do: 
# `git show-ref main` gives:
  # 6e5c94caa9d353838e84494c6eb0cacc8392e1c2 refs/heads/main
  # 6e5c94caa9d353838e84494c6eb0cacc8392e1c2 refs/remotes/origin/main
# then `cut -d ' ' -f1` gives:   # actually can be replaced by `git show-ref main --hash`
  # 6e5c94caa9d353838e84494c6eb0cacc8392e1c2
  # 6e5c94caa9d353838e84494c6eb0cacc8392e1c2
# then `head -n 1` return the first string


# query all branches for the most recent commit and check if it is identical.
# Write all branch identifiers for jobs without outputs into a file.
for i in $(git branch -a | grep job- | sort); do [ x"$(git show-ref $i \
  | cut -d ' ' -f1)" = x"${gitref}" ] && \
  echo $i; done | tee code/noresults.txt | wc -l
# Note: ^^ for each branch, check if its hash is the same as the main's hash; 
  # if so, this branch does not have results --> echo & save to `code/noresults.txt`
  # if not equal, this branch has results --> echo & save to `code/has_results.txt` (see below)

for i in $(git branch -a | grep job- | sort); \
  do [ x"$(git show-ref $i  \
     | cut -d ' ' -f1)" != x"${gitref}" ] && \
     echo $i; \
done | tee code/has_results.txt

mkdir -p code/merge_batches
num_branches=$(wc -l < code/has_results.txt)   # count lines
CHUNKSIZE=5000
set +e   # okay even errors
num_chunks=$(expr ${num_branches} / ${CHUNKSIZE})
if [[ $num_chunks == 0 ]]; then
    num_chunks=1
fi
set -e   # if there is error, exit
for chunknum in $(seq 1 $num_chunks)
do
    startnum=$(expr $(expr ${chunknum} - 1) \* ${CHUNKSIZE} + 1)
    endnum=$(expr ${chunknum} \* ${CHUNKSIZE})
    batch_file=code/merge_branches_$(printf %04d ${chunknum}).txt
    [[ ${num_branches} -lt ${endnum} ]] && endnum=${num_branches}    # if `num_branches` < `endnum`, then assign `num_branches` value to `endnum`
    branches=$(sed -n "${startnum},${endnum}p;$(expr ${endnum} + 1)q" code/has_results.txt)
    # ^^: `sed` is to parse text file. This should select the branch names from `startnum` to `endnum` from `has_results.txt` file
    echo ${branches} > ${batch_file}
    git merge -m "fmriprep results batch ${chunknum}/${num_chunks}" $(cat ${batch_file})   # git merge the branches listed above
    # ^^ for fmriprep.zip: <1 sec per branch, if very few branches in total.

done

# Push the merge back
git push    # ????what's this for, if we have `datalad push --data nothing` later?

# Get the file availability info
git annex fsck --fast -f output-storage   # ???? 
# ^^: <1sec per branch (fmriprep.zip + freesurfer.zip), if very few branches in total.

# This should not print anything
MISSING=$(git annex find --not --in output-storage)   # ????

if [[ ! -z "$MISSING" ]]
then
    echo Unable to find data for $MISSING
    exit 1
fi

# stop tracking this branch
git annex dead here    # ??????

# --> FAIRly big paper: push consolidated provenance records and file availability metadata to permanent storage
datalad push --data nothing   # push back to `output_ria`, but what does nothing mean???
echo SUCCESS

