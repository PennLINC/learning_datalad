#!/bin/bash

# Notes: if datalad has error 

conda_env="mydatalad"

conda create --name ${conda_env} python=3.9
conda activate ${conda_env}

# in this new env, install datalad, git, and git-annex:
conda install -c conda-forge datalad git git-annex

# check the versions:
datalad --version
git --version

# try out datalad to confirm it's error free:
datalad create -c text2git my-dataset

# If you're following the `rdm-course` by Adina in 2022, best to make sure other tools are installed as well:
# link [here](https://psychoinformatics-de.github.io/rdm-course/setup.html)