#!/bin/bash

* Notes: if datalad has error, try making a new conda env just for datalad and install datalad there :)
* Also see:
    * How to set up datalad:
        * [datalad handbook](https://handbook.datalad.org/en/latest/intro/installation.html)
        * See YouTube video: https://www.youtube.com/watch?v=IXSE-KtQVBs&t=61s
            * start from the beginning

# Step 1. create a new conda env just for datalad:
```
conda_env="mydatalad"

conda create --name ${conda_env} python=3.9
conda activate ${conda_env}
```

# Step 2. Install datalad and dependencies:
## Step 2.1 Installation
In this new env, install datalad, git, and git-annex:
### [ON LINUX]: install in one command as below:
```
conda install -c conda-forge datalad git git-annex   
# replace `install` with `update` to upgrade versions
```

### [ON MAC with M1 chip]:
It seems installing `git` again is not necessary as long as it is on the system. So we can skip that.

#### 1. install `git-annex` from source using `brew`:
```
brew install --build-from-source git-annex
```
Note: Recently (Feb 8th, 2023) CZ found that `git-annex` cannot be successfully installed on a Mac M1 chip laptop with above command - see [here](https://github.com/Homebrew/homebrew-core/pull/121594) for more details regarding the issue.
If you have trouble installing `git-annex` too, might considering `brew install datalad` - see [a section below](#alternative-way-for-mac).

#### 2. install datalad:
```
pip install datalad   # tested with Mac with M1 chip;
```

#### Alternative way for Mac:
On Mac, according to the [DataLad handbook](https://handbook.datalad.org/en/latest/intro/installation.html#mac-incl-m1), we could also use `brew install datalad` to install datalad + its dependencies, e.g., `git-annex`.

<details>
<summary>However there might be some issues...</summary>
<br>
On Feb 8th, 2023, CZ found that although this installation was successful on a Mac M1 chip laptop, it brings some issues with `datalad-osf` (i.e., after installing `datalad-osf` with `pip install`, it will have error when `datalad osf-credentials`: "datalad: Unknown command 'osf-credentials'."). 

To fix this issue, you need to `brew uninstall datalad` (note that `git-annex` will be kept so `brew install datalad` is still a way to install `git-annex`...), and reinstall `datalad` with `pip install datalad` in the conda environment. Sometimes the conda environment has been messed up (e.g., when `datalad --version` it will point to the brew-installed datalad which no longer exists anymore), so might need to remove this conda environment and reinstall it... 
</details>

## Step 2.2 Configuration

If you haven't configure your Git's `user.name` and/or `user.email`, please do so before using DataLad. This usually happen after e.g., creating a new CUBIC project or using a new computer.
```
git config --global user.name "FIRST_NAME LAST_NAME"
git config --global user.email "MY_NAME@example.com"
```

### Step 2.3 Checks
#### Step 2.3.1 check the versions:
```
datalad --version
git --version
git-annex version
```

#### Step 2.3.2 try out datalad to confirm it's error free:
```
datalad create -c text2git my-dataset
```

# (Optional) Step 3. Install `datalad_container`
If you will use container to process the data, you need to install `datalad_container`:
```
pip install datalad_container
```

To check installed version: `datalad containers-add --version`

# (Optional) Step 4. Install `datalad-osf` 
If you need to publish dataset onto OSF, or clone dataset from OSF, you need to install `datalad-osf`:
```
pip install datalad-osf
```
Then please make sure you set it up:
```
datalad osf-credentials  
```
And provide your OSF token when asked (see below for more). This step is very important; without this it might cause error that's hard to debug...
<details>
<summary>More details...</summary>
<br>
When asked osf token: check if you have existing tokens [here](https://osf.io/settings/tokens).
If you already created one, you might have save it somewhere else - the token is a list of random characters.
</details>

To check installed version: `datalad osf-credentials --version`

# (Optional) Other packages
If you're following the `rdm-course` by Adina in 2022, best to make sure other tools are installed as well: link [here](https://psychoinformatics-de.github.io/rdm-course/setup.html).
