
## Basic tips
* If you messed up with `datalad` or `git-annex`, try start from the beginning, e.g., create a new project
* file content availability: better to be consistent in one location,
    * check `git annex whereis <filename>` (or without `<filename>`)
    * e.g., `datalad drop *` to make sure all are not here.

## Steps you might go over when debugging errors without apparent idea/solution
When facing an error, please check out if there is solution to this specific question (see sections below). If not, follow these steps:

1. Does the error happen only in this clone, or?
    * try in the source ds?
    * if you clone it to another dir (either directly clone, or clone from e.g., OSF): still error?
1. Just this file, or also other files?
    * e.g., if you received error when `datalad get`, try out `datalad get *` to see if there are other problematic files
    * If only one specific file gets this problem, might check that specific one
        * e.g., re-generate it?
        * `git-annex whereis <filename>`, `git-annex fsck <filename>`, and compare printed messages with other "good" files'
1. Can you replicate the same error with another datalad ds of some random files?
    * command to generate file of random data: `head -c 1024 </dev/urandom >myfile`
        * you can replace `1024` with the file size you want (unit: byte)
        * you can replace `myfile` with the filename you want
        * ref: [here](https://unix.stackexchange.com/questions/33629/how-can-i-populate-a-file-with-random-data)
    * if error message is from git-annex tracked files, please generate binary files of random data: I guess without extension, or e.g., `.nii.gz`?
    * if error message is from git tracked files, please generate text files (if the ds was created with `datalad create -c text2git`): I guess e.g., `.txt`?
    * after `datalad save`, please `tree` and confirm that the file is indeed tracked (or not tracked) by git-annex - i.e., if as expected?
1. Update versions of `datalad`, `git`, `git-annex`, `datalad-osf`
    * however this might solve the problem... Or it appears to fix, but the problem itself was not reproducible (sometimes happen, sometimes not) so it "comes back" again

## Creating datalad dataset
### This is actually normal: if a directory is empty
It won't be tracked by datalad or git.


## Data processing
### input data has some problem
e.g., cannot identify file xxxxx

This indicates that the file content has some problem. Therefore we need to check if the file is valid. As the data is tracked by datalad, you need to:
* (optional) `datalad get <filename>`  # load the file onto your disk, if needed
* `datalad unlock <filename>`   # you're now ready to modify them

Now you can see if the file is valid - treating it as a plain file.

After replacing with the valid file, make sure you `datalad save`.

### output file: Permission denined
e.g., PermissionError: [Errno 13] Permission denied: <output_filename>

## Collaboration
### When `datalad push --to gin`, it's stuck (percent < 100%)
e.g., Update availability for 'gin':  75%|█████████████████▎     | 3.00/4.00

If you are using vscode, check if there is a pop out window at the upper band of vscode! It's waiting for you to enter the username and password for GIN [facepalm]

### General debugging with dataset that has siblings (e.g., OSF, or just cloned ds):
* Is there any untracked changes in the source ds?

### Cannot `datalad get` a file from OSF
but other files are (or might be) fine.

Possible Solutions:
* check if `datalad osf-credentials` has been set up (if not, please provide your OSF token when asked)
* check if all the files are tracked by `git-annex` (unless you set up the datalad repo by: `-c text2git`): `git-annex fsck`
* If it's only a specific file is problematic, re-generate this file, and `datalad save`, `datalad push --to osf`
* do everything from beginning:
    * `cp -rl` to copy out the data to a new folder
    * `datalad create`   # try out `-c text2git` if the problematic file is json file
    * `datalad save`
    * `git-annex fsck`: double check
    * `datalad status`
    * push to osf

### `datalad get` gives an error message as below:
```
# e.g., in cloned output RIA:
$ datalad get xxx.zip
[ERROR  ] Received undecodable JSON output: b"runHandler: couldn't find handler"
get(ok): xxx.zip (file) [from output-storage...]
```
Although there is this error message, otherwise this file looks fine:
* the file content is fine (can view images in this zip file; can `cat xxx.json` that's in this zip file);
* `git-annex fsck` of this file is also fine.

So,
* [STATUS] not resolved; not a reproducible error
* [TRIED] upgrade `datalad`, `git`, and `git-annex`
* [PRIORITY] low. can ask during datalad office hour if time permits.


## When running on a cluster
Sometimes the cluster might be very slow so some actions were not successfully completed.

If using vscode, might add `PYDEVD_WARN_EVALUATION_TIMEOUT` to `.vscode/launch.json`. See [here](https://stackoverflow.com/questions/65093883/how-do-i-turn-off-the-evaluating-plt-show-did-not-finish-after-3-00s-seconds) for more.