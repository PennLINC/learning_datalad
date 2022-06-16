# How to unzip exisitng results?

Currently there are three ways:

* custom unzip: queue for each zip; It's safe but slow
* `datalad clone --reckless ephemeral`: it's unsafe, though it's very quick
    * It creates a symlink to the original RIA. If delete the copy, the original RIA will also be deleted....
* `add-archive`: seems still under figuring out by Sydney...