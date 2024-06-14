# Run BREW3R on a cluster with slurm scheduler

You need to update the template config file available [here](./config_template.sh) so the paths match what you have on your cluster.

Then simply run:
```bash
bash  master.sh config_template.sh
```

This will run 2 jobs:
- first one will run individual stringtie as a job array (one job per BAM file).
- second one will run the merge of stringtie and the extension with the R script but only when the first one has finished.
