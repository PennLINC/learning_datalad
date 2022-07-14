# This markdown file lists the basic datalad functions


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





