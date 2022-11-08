
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

### Cannot `datalad get` a file from OSF
but other files are (or might be) fine.

Possible Solution: check if `datalad osf-credentials` has been set up (if not, please provide your OSF token when asked)

## When running on a cluster
Sometimes the cluster might be very slow so some actions were not successfully completed.

If using vscode, might add `PYDEVD_WARN_EVALUATION_TIMEOUT` to `.vscode/launch.json`. See [here](https://stackoverflow.com/questions/65093883/how-do-i-turn-off-the-evaluating-plt-show-did-not-finish-after-3-00s-seconds) for more.