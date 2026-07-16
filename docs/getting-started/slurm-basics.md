# Slurm Basics

## Common Slurm commands
### `sinfo`
`sinfo` and is a command that lets you see the cluster status. I have ran `sinfo` on Muscadine during a low usage time so all the nodes are idle. It is *highly* recommended to check this before submitting jobs, specifically greater than half a node in size.
```bash
╰─$ sinfo
PARTITION  AVAIL  TIMELIMIT  NODES  STATE NODELIST
muscadine*    up   infinite      5   idle muscadine-node-[1-5]
```

### `squeue`
`squeue` is a command that allows you to see any current jobs running on the cluster. This is very useful if you want to monitor if your job is running/waiting for resources along with its Job ID. I ran it on Muscadine while I have my meta-8B.sh running.
```bash
╰─$ squeue
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
     3449 muscadine meta-8B.    odh49  R       0:18      1 muscadine-node-2
```

### `scancel`
`scancel` kills a Slurm job. This is useful if you realize there was a mistake in your SBATCH file, made a change before it finished, or if it was an interactive job that froze. Here I used the Job ID from my job previously shown to kill the model running.
```bash
╰─$ scancel 3449
```

### `sacct`
`sacct` is like `squeue` except it shows all Slurm jobs that have been ran, is running, or errored out solely by you. This is very useful when looking at several jobs and seeing how its being handled. Here is the output of `sacct` with a few things running, ran, and failed.
```bash
╰─$ sacct
JobID           JobName  Partition    Account  AllocCPUS      State ExitCode
------------ ---------- ---------- ---------- ---------- ---------- --------
3449         meta-8B.sh  muscadine     sighpc          2 CANCELLED+      0:0
3449.batch        batch                sighpc          2  CANCELLED     0:15
3449.0        llama-cli                sighpc          2  CANCELLED     0:15
3450          llama-cli  muscadine     sighpc          2     FAILED      0:2
3450.0        llama-cli                sighpc          2  CANCELLED      0:2
3451         meta-8B.sh  muscadine     sighpc          2    RUNNING      0:0
3451.batch        batch                sighpc          2    RUNNING      0:0
3451.0        llama-cli                sighpc          2    RUNNING      0:0
3452         helloWorld  muscadine     sighpc         48    RUNNING      0:0
3452.batch        batch                sighpc         48    RUNNING      0:0
3452.0        hello_mpi                sighpc         48    RUNNING      0:0
```

### `srun`
`srun` is the command you'll use to run a parallel program via Slurm. For the most part, you'll use this within an SBATCH script described in Section 5.3. But if you want an interactive session (eg. `srun -c2 --pty bash`). Using `srun` is also useful when testing code on a small scale before fully implementing the SBATCH for it. Check out https://slurm.schedmd.com/srun.html for a full list of arguments to use with `srun`.


## Building a SBATCH script
SBATCH Scripts are what are used by Slurm to better allocate/distribute your program. Below is a template you can use for nearly any Slurm job.

```SBATCH
!/bin/bash

 Slurm Specific

SBATCH --job-name="my_name"            #job name
SBATCH --nodes=1                       #number of nodes
SBATCH --ntasks-per-node=16            #number of tasks per node
SBATCH --cpus-per-task=1               #number of physical cores per task
SBATCH --mem=4G                        #max memory allocated 
SBATCH --time=0-1:00:00                #max runtime (D-hh:mm:ss)
SBATCH --output=my_run.log             #output name


 Muscadine Specific

ml load <neededModules>


 Your Application

srun <application>
```

Here is an example of a SBATCH Script used for a Hello World spanning across 2 nodes, 48 threads each, using the openmpi/5.0.5 module, and the binary I made.

```SBATCH
!/bin/bash

 Slurm Specific

SBATCH --job-name=helloWorld           #job name
SBATCH --nodes=2                       #number of nodes
SBATCH --ntasks-per-node=48            #number of tasks per node
SBATCH --cpus-per-task=1               #number of cpus per task
SBATCH --mem=8G                        #max memory allocated
SBATCH --time=0-1:00:00                #max runtime
SBATCH --output=helloWorld-%j.out      #output name


 Muscadine Specific

ml load openmpi/5.0.5


 Your Application

srun ./hello_mpi
```

You can submit the SBATCH Script to Slurm via the following command:

```bash
sbatch <sbatchScript>
```
