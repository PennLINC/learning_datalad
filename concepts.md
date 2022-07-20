Basic DataLad concepts

# RIA (Remote Indexed Archives)
refs:
* [DataLad handbook chapter](http://handbook.datalad.org/en/latest/beyond_basics/101-147-riastores.html#remote-indexed-archives-for-dataset-storage-and-backup)

* DEFINITION of RIA stores: dataset storage locations that allow for access to and collaboration on DataLad datasets
* Usually, looking inside of RIA stores is not necessary for RIA-related workflows, but it can help to grasp the concept of these stores.
* How to create an RIA:
    * `datalad create-sibling-ria`
        * note that in DataLad versions >0.16.0: A new store isn’t set up unless --new-store-ok is passed.

* Why there are `input_ria` and `output_ria`:
    * ref: FAIRly big paper
    * why `output_ria`: (also: `pushgitremote` in `participant_job.sh`)
        * otherwise, computing jobs are cloning and depositing outcomes --> slow; 
        * also, result deposition in a DataLad dataset is a write opertaion, should not concurrent read + write access.
    * why `input_ria`: (also: `dssource` in `participant_job.sh`)
        * in order to avoid unintential modifications (on the original copy) during long computations