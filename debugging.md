
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

