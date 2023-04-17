# This markdown file lists the basic datalad functions

## Very basic and useful commands

* `datalad status`: similar to `git status`
    * `datalad status --annex all`: also print out present vs total size of the dataset, i.e., some data content has been dropped
    * `git status` can also show some status information
    * `datalad -e <"commit" or "no">`: to speed up `datalad status` for deep dataset hierarchies/large datasets: not to comprehensively check subdataset. See more [here](http://handbook.datalad.org/en/latest/basics/101-146-gists.html#speed-up-status-reports-in-large-datasets).
    * `du -sh <folder/filename>` to print the folder or file size. Can also do: `du -sh *` to list all folders/files in the current directory
* `tig`: view the datalad history.
    * View the detailed history of a commit by hitting "Enter". Go up level or exit by hitting "q"
    * `git show`: show the last save/commit
    * `git log -n <a number>`: print the last n commits
    * Find the commit (including all provenance) related to a file: `git log <path/to/file>`
        * For a subdataset, make sure you cd into that subdataset, before running this command (otherwise getting empty results)
* `tree`
    * If you don't want to see the long symlinks, use `ls`, without adding `-l`
* `datalad <function name> -h` or `--help` for how to use
* list siblings of a datalad dataset - assuming you're in a datalad-ds:
    * `datalad siblings`; Or:
    * `git remote -v`
* check if there is something wrong with `gix-annex` in some files:
    * `git-annex fsck`

## Create a DataLad dataset

* Create a DataLad dataset of a non-empty folder:
    * Option 1: Create a new folder:
        * go to one folder above of this non-empty folder.
        * `datalad create <foldername>` will create a new folder named `<foldername>`
        * cd to `<foldername>`, copy the data from that non-empty folder (`cp -r`)
        * `datalad save -m <message>`
    * Option 2: force to directly create DataLad dataset in this non-empty folder: ref [here](https://pennlinc.github.io/docs/TheWay/CuratingBIDSonDisk#testing-pipelines-on-example-subjects)
        * cd to this non-empty folder
        * `datalad create -d . --force -D "<description>"`
            * "--force": enforces dataset creation in non-empty dir
            * "-D": description


## Run the command with datalad tracking: `datalad run`
`datalad run` = get inputs + unlock outputs + change + save

"get inputs" means to get the input file contents

* In addition, detailed human readable info is saved and can be viewed with `tig`

```
datalad run \
    --input <a list of input files> \
    --output <output filename> \
    -m "your message" \
    "<your command as normal> --myInputs {inputs} --myOutputs {outputs}"    # no need to repeat inputs and outputs again! Note: sometimes need to quote ("") this line | change arguments "--myInputs" etc as appropriate
```

More notes:
* To view the expanded command (with {inputs} and {outputs} filled in) looks good to you or not before really running it, you can add `--dry-run basic` after `datalad run`. This will not actually execute the command
* If there is subdataset in current dataset, make sure explicitly specify the dataset this history will go to, by adding `-d <which_dataset>`
    * If it's current dataset: `-d .`
    * If it's the subdataset, e.g., called "inputs": `-d inputs`
* Debugging: if `-i` or `-o` values have globs (filenames including `*`), make sure the values are quoted (`''`)!!! e.g., `-i 'inputs/data/BIDS/*json'`
    * Otherwise, the full command of `datalad run` may miss `-i` or `-o` for expanded globs!

## Drop the content: `datalad drop` --> `datalad get`
If the data was got by `datalad` function, e.g., `datalad download-url`, then the file content can be dropped, but the information about its presence and history are maintained.

However, for file got by manual way (not `datalad` command) + `datalad save` probably cannot apply`datalad drop`, otherwise probably faced with an error .

Another situation where `datalad drop` fails, is when there is no other copy of a file elsewhere.

`datalad drop <filename>`

Now, the file cannot be accessed as a regular file.

If you want to get the content back and make the file as a regular one:

`datalad get <filename>`


## Commit: `datalad save`
If you change something by plain command (instead of `datalad run`), do:
`datalad save -m "your message"`

## Remove a dataset or components from a dataset: `datalad remove`
ref: [rdm-course by Adina 2022](https://psychoinformatics-de.github.io/rdm-course/92-filesystem-operations/index.html)

`datalad remove` is the antagonist command to `datalad clone`

### Remove a file from a dataset:
`datalad remove <path/to/file>`

If there is no other copies of this file elsewhere, it will throw out an error. If you're very sure to move it, add `--nocheck`.


### Remove a dataset:
```
datalad siblings    # check if it has a sibling & this sibling has all commits that the local dataset has, too. Otherwise `datalad remove` will fail.

cd ..   # get outside of the dataset you want to remove
datalad remove -d <path to the dataset you want to remove>
```


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
* (optional) remove recent commits by `git reset`. Example see the last command in [this section in DataLad Handbook](http://handbook.datalad.org/en/latest/basics/101-136-filesystem.html#renaming-files)

# Collaborate with more than one copy of dataset
Summary: ref: [rmd workshop by Adina 2022](https://psychoinformatics-de.github.io/rdm-course/03-remote-collaboration/index.html#interim-summary-interacting-with-remote-datasets)

A different place = another storage, GitHub, [GIN](https://gin.g-node.org), cloud, etc

* A different place --> Your workstation:    Consume existing datasets and stay up-to-date
    * `datalad clone`:  consume an existing dataset
    * `datalad update`: keep siblings in sync
* Your workstation --> A different place:   Create sibling datasets to publish to or update from
    * `datalad create-sibling`: create a sibling dataset to publish or update from
    * `datalad push`:   publish the dataset
* local --> a different place

Specifically, "data siblings" makes the communication between two copies easier (can update each other; also know each other's status). Commands related to "datalad siblings":

* `datalad siblings`
    * + `add`: add another dataset (`-url <url>`) as a sibling of local dataset (e.g., `-d .`), and give this sibling a name `--name <name>`
* `datalad install`
    * to create a local sibling of an existing dataset from a (remote) location identified via a URL or path.
* `datalad create-sibling`
    * ??? what's the difference vs the other two functions???

## Publish dataset: `datalad create-sibling` --> `datalad push`
e.g., to GIN - ref: [rdm workshop by Adina 2022](https://psychoinformatics-de.github.io/rdm-course/03-remote-collaboration/index.html#publishing-to-gin-datalad-push)

1. create an empty repo & set up `datalad siblings`
1. `datalad push`

## Clone data with `datalad clone` --> `datalad get` --> (optional) `datalad unlock`
Act like a data consumer.

1. `datalad clone <url/local dir> <local_foldername>`
* `url/local dir` =
    * If it's RIA store: using: (see more explanation [here](https://handbook.datalad.org/en/latest/beyond_basics/101-147-riastores.html#cloning-and-updating-from-ria-stores))
        * `ria+http://<url>#~<alias name>`
        * `ria+file://<folderpath>#~<alias name>`, for example `ria+file:///cbica/projects/xxx/xxx/qsiprep/output_ria#~data` is used for RIA store on a local file system (e.g., both on CUBIC, make sure current project has read access to the project that has this RIA store)
        * `ria+ssh://[user@]hostname:/cbica/projects/xxx/xxx/qsiprep/output_ria#~data` is used for RIA store on an SSH-accessible server (e.g., CUBIC, make sure personal user has read access to this CUBIC project)
        * here the `<alias name>` = the foldername in `<folderpath>/alias`
    * If it's just a datalad dataset on the same machine, e.g., on cubic:
        * simply use the `<path/to/folder>`, without anything more!
        * e.g., `/cbica/projects/xxx/raw_bids/`
    * If it's just a datalad dataset on the internet, just provide the url:
        * e.g., `https://github.com/datalad-datasets/longnow-podcasts.git`
        * e.g., `http://example.com/dataset`
    * If it's datalad ds on OSF:
        * `osf://<id>`
            * before using this, make sure: 1. you are in a conda env that has datalad-osf installed
            * and, 2. make sure you also set up `datalad osf-credentials` (please provide your osf token when asked)
* `local_foldername` is for the foldername that will be created and where the cloned data will be. This is different from `git clone` where this isn't specified, and the same dataset name will be used as the foldername.
* notice that by now the annexed content hasn't been downloaded.
    * `datalad status --annex all` to check how much data size downloaded - make sure `cd <into_root_path_ds>` first
* check where the file content is:
    * `git annex whereis <filename>`
* additional argument: if you want to clone a dataset as subdataset: add `-d .` meaning clone this new dataset as subdataset of the current datatset

2. `cd <into_root_path_ds>`, then `datalad get <filename>`
* by now, you got the file content
* however, currently the file content are at `.git/annex`, and the "files" are still symlinks to `.git/annex`
    * if files are photos, you can view them as usual (symlinked to the actual content)
    * but because of git-annex, the files are write-protected
3. (optional) `datalad unlock <filename>` so that files look like "regular files" without symlinks
    * but you removed the write-protection!
    * After unlocking, it's important to do `datalad save` to lock again!!

| command      | `datalad clone` | `datalad get`     | `datalad unlock` |
| :---        |    :----:   |          :---: | :---: |
| Copied file content?      | not yet       | yes, at `.git/annex`   | yes |
| Files appear as symlinks? (`tree <folder/filename>`)   | yes        | still yes | not anymore - appear as regular files |
| write protection? | - | yes! | nope, just as regular files |
| antagonist | `datalad remove` | `datalad drop` | `datalad save` (kind of; will lock it) |

Notes:
* After `datalad unlock`, if you want to `datalad drop`, you don't need to `datalad save` first!
* After `datalad unlock`, even without any changes on the file content itself, this file will appear as "modified" when `datalad status`. That's fine! After you `datalad save` this file, you'll see there is no new commit:
    * way 1: should be "save (notneeded: 1)" when `datalad save`;
    * way 2: use `git log --oneline` to check the commit list
* currently `ria+ssh`:
    * will throw out weird information `[INFO   ] RIA store unavailable.` but it seems it does not affect cloning?
    * might need to configure `ssh` first? (if not using username?) See below. - Matt said he created an issue on datalad github.
```
chmod 700 ~/.ssh
cd ~/.ssh
vim config
```
```
# add these to this config:
Host <name>
    HostName <name>.xx.xx.com
    User <personal_username>
```
```
# finally:
chmod 600 ~/.ssh/config
```

## Update the dataset / keep siblings in sync: `datalad update`

Assume: original copy --> gin --> another copy

* In the original dataset, make some actions with `datalad run`;
* before next step, make sure you're in a conda env with `datalad-osf` installed!
* push to remote: `datalad push --to <somewhere>`
    * `<somewhere>` = osf, gin, origin, etc
        * for `osf`, there would be another sibling of the dataset (`datalad siblings`) called e.g., `osf-storage`, and here we don't use that, but just use `osf`
* cd to "another copy": `datalad update -s origin --how merge`

Compared to Git: # ref: [DataLad Handbook](http://handbook.datalad.org/en/latest/basics/101-119-sharelocal4.html)
* `datalad update` ~ `git fetch`
* `datalad update --merge` ~ `git pull`

## Remove a sibling (inclu. OSF)
```
# find the name of the sibling you want to remove:
git remote -v    # or:
datalad siblings

# remove:
datalad siblings remove -s <name>  # <name> of the sibling

# confirm it's removed:
datalad siblings    # should only be 'here'
git remote -v    # shouldn't be anything

```

For OSF, you might need to remove twice:
```
datalad siblings remove -s osf   # or your specific osf sibling name
datalad siblings remove -s osf-storage   # or your specific one
```
Now you can delete OSF project on the webpage.

# Reproduce
## Rerun
`datalad rerun <shasum>`


Notes:

* The file content of the input file does not need to be `get` first; `datalad rerun` will handle it.
* Basically `datalad rerun` also does the same steps as `datalad run` = get inputs + unlock outputs + change + save

# Subdatasets
PLEASE BE AWARE that if you are dealing with a subdataset within a superdataset, there are several things that you might be confused "why this command does not work?!" although the command works for a regular dl dataset.

## DEBUGGING:
* If you only cloned the subdataset with `datalad clone`, make sure you clone the necessary metadata too: `datalad get -n <subdataset foldername>`. This command with `-n` is not to get the content, but only to clone subdataset
* If something does not work, try to cd into that subdataset first!

 a superdataset does not record individual changes within the subdataset, it only records the state of the subdataset.  In other words, it points to the subdataset location and a point in its life (indicated by a specific commit).

 # How to view previous versions of files and dataset?
 ref: [Datalad Handbook](http://handbook.datalad.org/en/latest/basics/101-137-history.html#viewing-previous-versions-of-files-and-datasets)
 * Option 1:
    * git log -n <number of history> --oneline   # find the <shasum> you want to go to
    * `git checkout <shasum>`
    * view something via e.g., `tail <filename>`
    * `git checkout master`   # return
* Option 2:
    * `git cat-file --textconv SHASUM:<path/to/file>`  # please check out the notes on the DataLad handbook for this option!

# Metadata
## Search/Query metadata of a dataset
metadata = filenames, availability
e.g., wanted to know actions done by an author; and I guess probably search something in the provenance record e.g., a filename --> get related command done upon this file? But I know a better way: git log <path/to/this/file>