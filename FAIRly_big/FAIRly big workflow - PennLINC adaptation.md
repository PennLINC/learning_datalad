FAIRly big workflow - PennLINC adaptation

Example script:
* with my notes, see:
    * scripts in folder [bootstrap_egCode](bootstrap_egCode), e.g., [bootstrap_egCode/participant_job.sh](bootstrap_egCode/participant_job.sh)
    * `babs_tests/testdata/bootstrap-fmriprep-multises-NKI-exemplar.sh`
* fMRIPrep, QSIPrep: one input dataset of raw BIDS data
* XCP-D: one input dataset of fMRIPrep's outputs
* two input datasets:
    * e.g., running fMRIPrep but given that FreeSurfer outputs already exist (and now as an input dataset)
        * example script [bootstrap-fmriprep-ingressed-fs.sh](bootstrap-fmriprep-ingressed-fs.sh)


# Step 2. Prepare BIDS App container
Q: where did my .sif go?
A: it's in dir: `<container_dataset>/.datalad/environment/<name-container>`, and it's `image` in this hidden dir.
    where `<name-container>` is the name you gave when you `datalad containers-add`,



# Step 4. Bootstrap
## BIDS App container
Currently, the container dataset will be installed into `${PROJECTROOT}/pennlinc-containers` folder
## What does `bootstrap.sh` script do?
* create a datalad dataset of this analysis
    * clone the input data to `analysis/inputs/data`
    * clone the BIDS App datalad container dataset to `analysis/pennlinc-containers`
    * create siblings input_ria and output_ria
* in folder `analysis/code`, write out several scripts to be used:
    * `participant_job.sh`     # current version is CLUSTER-SPECIFIC; to remove those commands!
    * `bidsApp_zip.sh`
        * `singularity run` the bids app
        * zip the output folder of the bids app
    * `qsub_calls.sh`   # CLUSTER-SPECIFIC
    * `merge_outputs.sh`
        * clone the output_ria to a folder called `merge_ds`
        * list the branches to merge
        * merge branches (by chunk)
        * push the merge back
    * --> when coding `babs-init`: make sure only `qsub_calls.sh` is cluster specific!
* set ups (cont'd)
    * datalad drop `inputs/data`  # current command is `uninstall` which is deprecated...
    * push to input and output RIA
    * add an alias to the data in the RIA store

# Step 5. Run the participant's job
## temporary space when a job is running:
* where is it?
    * the root is either at `${CBICA_TMPDIR}`, or `/cbica/comp_space/$(basename $HOME)`
    * Then, cd to `<job-name>/ds`
        * example `<job-name>`: job-557304-sub-A00085942-ses-TRT   # this is a multi-session processing pipeline
* Folder structure:
```
[ds] $ tree -L 3
.
├── CHANGELOG.md
├── code
│   ├── fmriprep_zip.sh
│   ├── license.txt
│   ├── merge_outputs.sh
│   ├── participant_job.sh
│   ├── qsub_calls.sh
│   └── README.md
├── inputs
│   └── data
│       ├── dataset_description.json
│       └── sub-A00085942
├── pennlinc-containers
├── prep
│   └── fmriprep
│       ├── logs
│       └── sub-A00085942
├── README.md
└── ses-TRT_filter.json
```
Within folder `inputs/data/sub-A00085942`:
```
inputs/data/sub-A00085942/
├── ses-BAS1
│   ├── anat
│   └── func
├── ses-FLU1
│   ├── anat
│   ├── dwi
│   └── func
└── ses-TRT
    ├── anat
    ├── dwi
    └── func
```
And each folder of MRI modality contains BIDS data e.g,. .nii.gz, .json, etc

# Step 6. Audit
Audit is a bootstrap too.
It will create a folder in parallel of the original one, named e.g., `fmriprep-audit`.
The folder structure in this audit folder is similar to the original one, e.g., including `analysis`, `input_ria`, `output_ria`.
When auditing each participant's job, it will qsub a job to do so.