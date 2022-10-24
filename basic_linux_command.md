# Basic linux commands


## Peek text files:
* `head -n <number of lines> <filename>`   # first several lines
* `tail -n <number of lines> <filename>`   # last several lines

## Change file/folder permissions
* Debug: cannot write a file on cubic via vscode.
* Solution:
    * check `ls -l`, if the 2nd chunk (which tells the group's permission) is still `r--`, not `rw-` (without write permission)
    * if so, run: `chmod g+w /path/to/folder/*`; this will change permissions of all files in this folder
        * note that if not adding `*`, it will only change the permission of the folder...


# Commands and terms on CUBIC cluster
* check currently running job using `qstat`
    * check job status: `qstat | grep <jobid>`
        * adding `grep` is very helpful if there are too many qsub jobs on this project user
    * check job's info: `qstat -j <jobid>`
* check finished job using `qacct`
    * `qacct -j <jobid>`
        * notice that, it will print out several jobs in recent years, sharing the same job id. Only focus on the last, aka the latest chunk.
    * `qacct -j <jobid> | grep jobname` will only print the job name, which is easier to figure out what this job was for

## Space
* Temporary directory at compute node:  `${CUBIC_TMPDIR}`
    * by default, use it
    * It seems like it also has a name: "Scratch space"
* Compute space: `/cbica/comp_space/$(basename $HOME)`
    * e.g., `/cbica/comp_space/RBC`
    * This is good to check the temporary output data when the job is running
    * after the job is successfully finished, the folder will be deleted.
    * However, should not submit a lot of jobs running here! Will blow up the space...
