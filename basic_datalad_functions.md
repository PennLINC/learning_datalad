# This markdown file lists the basic datalad functions

## Very basic and useful commands

* `datalad status`: similar to `git status`
    * `datalad status --annex all`: also print out present vs total size of the dataset, i.e., some data content has been dropped
* `tig`: view the datalad history. 
    * View the detailed history of a commit by hitting "Enter". Go up level or exit by hitting "q"


## create a DataLad dataset

## `datalad run`
`datalad run` = unlock + change + save

* In addition, detailed human readable info is saved and can be viewed with `tig`

```
datalad run \
    --input <a list of input files> \
    --output <output filename> \
    -m "your message" \
    <your command as normal> {inputs} {outputs}    # no need to repeat inputs and outputs again!
```

## `datalad drop` --> `datalad get`
If the data was got by `datalad` function, e.g., `datalad download-url`, then the file content can be dropped, but the information about its presence and history are maintained. 

However, for file got by manual way (not `datalad` command) + `datalad save` probably cannot apply`datalad drop`, otherwise probably faced with an error .

`datalad drop <filename>`

Now, the file cannot be accessed as a regular file.

If you want to get the content back and make the file as a regular one:

`datalad get <filename>`


## `datalad save`
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





