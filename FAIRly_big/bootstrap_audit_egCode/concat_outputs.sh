#!/bin/bash
set -e -u -x
PROJECT_ROOT=/cbica/projects/RBC/chenying_practice/fmriprep-multises-audit
cd /cbica/projects/RBC/chenying_practice/fmriprep-multises-audit
# set up concat_ds and run concatenator on it
cd ${CBICA_TMPDIR}
datalad clone ria+file://${PROJECT_ROOT}/output_ria#~data concat_ds
cd concat_ds/code
wget https://raw.githubusercontent.com/PennLINC/RBC/master/PennLINC/Generic/concatenator.py
cd ..
datalad save -m "added concatenator script"
datalad run -i 'csvs/*' -o '${PROJECT_ROOT}/FMRIPREP_AUDIT.csv' --expand inputs --explicit "python code/concatenator.py csvs ${PROJECT_ROOT}/FMRIPREP_AUDIT.csv"
datalad save -m "generated report"
# push changes
datalad push
# remove concat_ds
git annex dead here
cd ..
chmod +w -R concat_ds
rm -rf concat_ds
echo SUCCESS

