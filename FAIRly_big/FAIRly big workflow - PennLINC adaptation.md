FAIRly big workflow - PennLINC adaptation
# Step 2. Prepare BIDS App container
Q: where did my .sif go?
A: it's in dir: `<container_dataset>/.datalad/environment/<name-container>`, and it's `image` in this hidden dir.
    where `<name-container>` is the name you gave when you `datalad containers-add`,



# Step 4. Bootstrap
## BIDS App container
Currently, the container dataset will be installed into `${PROJECTROOT}/pennlinc-containers` folder

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