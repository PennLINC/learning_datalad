# This markdown file lists the basic datalad functions

## Very basic and useful commands

* `datalad status`: similar to `git status`
    * `datalad status --annex all`: also print out present vs total size of the dataset, i.e., some data content has been dropped
* `tig`: view the datalad history. 
    * View the detailed history of a commit by hitting "Enter". Go up level or exit by hitting "q"
* `tree`
* list siblings of a datalad dataset - assuming you're in a datalad-ds:
    * `datalad siblings`; Or:
    * `git remote -v`


## Create a DataLad dataset

## Run the command with datalad tracking: `datalad run`
`datalad run` = get inputs + unlock outputs + change + save

"get inputs" means to get the input file contents

* In addition, detailed human readable info is saved and can be viewed with `tig`

```
datalad run \
    --input <a list of input files> \
    --output <output filename> \
    -m "your message" \
    <your command as normal> {inputs} {outputs}    # no need to repeat inputs and outputs again!
```

## Drop the content: `datalad drop` --> `datalad get`
If the data was got by `datalad` function, e.g., `datalad download-url`, then the file content can be dropped, but the information about its presence and history are maintained. 

However, for file got by manual way (not `datalad` command) + `datalad save` probably cannot apply`datalad drop`, otherwise probably faced with an error .

`datalad drop <filename>`

Now, the file cannot be accessed as a regular file.

If you want to get the content back and make the file as a regular one:

`datalad get <filename>`


## Commit: `datalad save`
If you change something by plain command (instead of `datalad run`), do:
`datalad save -m "your message"`


## How to "undo" a step?
ref is the [rdm-course by Adina 2022](https://psychoinformatics-de.github.io/rdm-course/01-content-tracking-with-datalad/index.html#breaking-things-and-repairing-them)

### If you only modified files but haven't `datalad save`:
!!! `git restore` is dangerous! All the unsaved modifications will be gone!!! 

`git restore <filename_of_the_file_you_changed>`

Now, the file content in the last commit should be restored.

### If you have `datalad save`
You need to `git revert` now:

* `tig`: e.g., top commit is the one you want to "undo" - the commit hash displays at the bottom of the window - copy the first 7 char out
* `git revert --no-edit <commit_hash>`
    * `--no-edit` means using the default commit message `Revert "xxxx"`; otherwise, you will be asked to edit the commit message
* (optional) remove recent commits by `git reset ???` # TODO


## Publish dataset: `datalad create-sibling` --> `datalad push`
e.g., to GIN - ref: [rdm workshop by Adina 2022](https://psychoinformatics-de.github.io/rdm-course/03-remote-collaboration/index.html#publishing-to-gin-datalad-push)

1. create an empty repo & set up `datalad siblings`
1. `datalad push` 

## Clone data with `datalad clone` --> `datalad get`
Act like a data consumer.

1. `datalad clone <url> <local_foldername>`
    * `local_foldername` is for the foldername that will be created and where the cloned data will be. This is different from `git clone` where this isn't specified, and the same dataset name will be used as the foldername.
    * notice that by now the annexed content hasn't been downloaded.
        * `datalad status --annex all` to check how much data size downloaded - make sure `cd <into_root_path_ds>` first
    * check where the file content is:
        * `git annex whereis <filename>`
2. `cd <into_root_path_ds>`, then `datalad get <filename>`

## Update the dataset / keep siblings in sync: `datalad update`

Assume: original copy --> gin --> another copy

* In the original dataset, make some actions with `datalad run`;
* push to remote: `datalad push --to <e.g., gin>`
* cd to "another copy": `datalad update -s origin --how merge`

## Rerun
`datalad rerun <shasum>`


Notes:

* The file content of the input file does not need to be `get` first; `datalad rerun` will handle it.
* Basically `datalad rerun` also does the same steps as `datalad run` = get inputs + unlock outputs + change + save