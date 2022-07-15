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
conda install -c conda-forge datalad git git-annex

# check the versions:
datalad --version
git --version

# try out datalad to confirm it's error free:
datalad create -c text2git my-dataset

# Step 3. install datalad_container, if you will use container to process the data:
pip install datalad_container


# If you're following the `rdm-course` by Adina in 2022, best to make sure other tools are installed as well:
# link [here](https://psychoinformatics-de.github.io/rdm-course/setup.html)
