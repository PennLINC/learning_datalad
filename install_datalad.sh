#!/bin/bash

# Notes: if datalad has error, try making a new conda env just for datalad and install datalad there :)
# Also see:
# * How to set up datalad:
#     * See YouTube video: https://www.youtube.com/watch?v=IXSE-KtQVBs&t=61s
#         * start from the beginning

conda_env="mydatalad"

# Step 1. create a new conda env just for datalad:
conda create --name ${conda_env} python=3.9
conda activate ${conda_env}

# Step 2. Install datalad:
# in this new env, install datalad, git, and git-annex:
# [ON LINUX]: install in one command as below:
conda install -c conda-forge datalad git git-annex
# [ON MAC with M1 chip]:
# 1. install `git-annex` from source using `brew`:
brew install --build-from-source git-annex
# 2. install datalad:
pip install datalad   # M1 Mac; see here for non-M1 Mac: https://handbook.datalad.org/en/latest/intro/installation.html#mac-osx-non-m1
# it seems installing git again is not necessary as long as it is on the system.

# If you haven't configure your Git's `user.name` and/or `user.email`,
#   please do so before using DataLad.
#   this usually happen after e.g., creating a new CUBIC project.
# $ git config --global user.name "FIRST_NAME LAST_NAME"
# $ git config --global user.email "MY_NAME@example.com"

# check the versions:
datalad --version
git --version

# check git-annex is well installed:
git-annex

# try out datalad to confirm it's error free:
datalad create -c text2git my-dataset

# Step 3. install datalad_container, if you will use container to process the data:
pip install datalad_container

# Step 4. install datalad osf, if you need to publish dataset onto OSF, or clone dataset from OSF:
pip install datalad-osf
# When asked osf token: see https://osf.io/settings/tokens
    # If you already created one, you might have save it somewhere else - the token is a list of random characters

# If you're following the `rdm-course` by Adina in 2022, best to make sure other tools are installed as well:
# link [here](https://psychoinformatics-de.github.io/rdm-course/setup.html)
