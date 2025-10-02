# User Documentation v1.0

Muscadine is MSU's Special Interest Group in High Performance Computing (SIG-HPC) cluster gifted to MSU by Dell for our 2024 GIGADAWGS team. Muscadine is currently operating as a student development cluster, being used to teach students at MSU skills in HPC.

## Table of Contents:
- 1: [Muscadine Specs](Muscadine#1%20Muscadine%20Specs)
	- 1.1: [Hardware Specification](Muscadine#1.1%20Hardware%20Specification)
	- 1.2: [Highest Benchmarks](Muscadine#1.2%20Highest%20Benchmarks)
- 2: [How to access Muscadine](Muscadine#2%20How%20to%20access%20Muscadine)
	- 2.1: [Method One - Titan](Muscadine#2.1%20Method%20One%20-%20Titan)
	- 2.2: [Method Two - HPC VPN](Muscadine#2.2%20Method%20Two%20-%20HPC%20VPN)
- 3: [Muscadine's Storage](Muscadine#3%20Muscadine's%20Storage)
- 4: [How to use Muscadine](Muscadine#4%20How%20to%20use%20Muscadine)
	- 4.1: [Getting a node allocation](Muscadine#4.1%20Getting%20a%20node%20allocation)
	- 4.2: [Available modules](Muscadine#4.2%20Available%20modules)
	- 4.3: [What do I do if there is a program I want?](Muscadine#4.3%20What%20do%20I%20do%20if%20there%20is%20a%20program%20I%20want?)
- 5: [How to use Slurm](Muscadine#5%20How%20to%20use%20Slurm)
	- 5.1: [Common Slurm commands](Muscadine#5.1%20Common%20Slurm%20commands)
		- 5.1.1: [sinfo](Muscadine#5.1.1%20`sinfo`)
		- 5.1.2: [squeue](Muscadine#5.1.2%20`squeue`)
		- 5.1.3: [scancel](Muscadine#5.1.3%20`scancel`)
		- 5.1.4: [sacct](Muscadine#5.1.4%20`sacct`)
		- 5.1.5: [srun](Muscadine#5.1.5%20`srun`)
	- 5.2: [Building a SBATCH script](Muscadine#5.2%20Building%20a%20SBATCH%20script)
- 6: [Need Help?](Muscadine#Need%20Help?)
 ## <div style="page-break-after: always;"></div>
## 1: Muscadine Specs
### 1.1: Hardware Specification
#### Compute:
- 5x Nodes:
	- 1x AMD EPYC Genoa 9454P 48 core CPU
	- 12x 16 GB DDR5 4800MT/s (192GB total)
	- 1x Nvidia/Mellanox HDR 200Gbit/s HCA
	- 1x AMD Radeon Instinct MI210 (64GB) GPU
#### Storage:
- BeeGFS
	- 5x BOSS-N1 RAID-1 Arrays
	- mounted on `/scratch`
	- 2.2TB Distributed Filesystem
- PureStorage Flashblade
	- Clustered flash array
	- 6 16TB blades for 96TB raw storage
	- mounted on `/home`, `/work`, and `/apps`
	- 48TB usable space (w/ 100% redundancy)
#### Networking:
- HDR Infiniband Switch
	- 24x HDR ports
	- Used for:
		- Performant Cluster Communication
		- RDMA BeeGFS
- Gigabit Switch
	- 48x Gigabit ports
	- Provides admin and cluster management

 ###  <div style="page-break-after: always;"></div>
### 1.2: Highest Benchmarks

Here, we have the students with the highest scores for various cluster benchmarking programs. In order to get your score verified, email your entire config and output file to the current student sysadmin.

#### High-Performance Linpack (5-node):
- 1st place: Drew Helgerson - 11.8 TeraFlops
- 2nd place: 
- 3rd place:

#### High-Performance Linpack (single node):
- 1st place: Drew Helgerson - 2.405 TeraFlops
- 2nd place: Oliver Higginbotham - 2.371 TeraFlops
- 3rd place: 
#### MLPerf:
- 1st place:
- 2nd place:
- 3rd place:
 ## <div style="page-break-after: always;"></div>
## 2: How to access Muscadine

### 2.1: Method One - Titan

First log into Titan at `titan.hpc.msstate.edu`. Use the following template if needed:

```bash
ssh <NetID>@titan.hpc.msstate.edu
```

After entering your HPC password and doing the 2FA push, you can proceed to logging into Muscadine. Muscadine only has one node facing the HPCC network which is `muscadine-node-1`, so that is the one we'll want to ssh into. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```

Repeat the authentication process from logging into Titan and you'll be set.

### 2.2: Method Two - HPC VPN

Method Two involves logging into the HPCC VPN. Go to https://servicedesk.its.msstate.edu/TDClient/45/Portal/KB/?CategoryID=80 and download the Cisco AnyConnect VPN by following ITS's guide. Once that is completed, launch the VPN and connect to `vpn.hpc.msstate.edu`. It will then ask for your Group (HPC2), Username (your NetID), Password (your HPC Password), and Duo 2FA Passcode (get from duo app). Once you are connected, you can ssh directly into muscadine's head node `muscadine-node-1`. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```

 ## <div style="page-break-after: always;"></div>
## 3: Muscadine's Storage

You are provided a decently fast and shared home directory. This is the location you start after ssh-ing into Muscadine. You are welcome to keep stuff in your home directory, but there are also `/scratch` and `/work` that you can use.

`/scratch` is build off of the BeeGFS and is the most performant storage solution for Muscadine. The downside is that there is limited storage, thus there will be wipes of old files every now and then whenever it gets near capacity.

`/work` and `/home` are based on the same storage solution so they have the same speed. The difference is that `/work` is intended for project data such as datasets, AI models, output files, etc. If your program intakes data or outputs data, that data should be stored in `/work`.

| Mount      | Total Capacity | Speed      | Quota | Description                                                                                                                                                  |
| ---------- | -------------- | ---------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/scratch` | 2.2TB          | ***FAST*** | None  | Scratch is to be used for active data or programs that are not vital. ***SCRATCH WILL BE PERIODILY WIPED***                                                  |
| `/home`    | 20TB           | *quick*    | 10GB  | Home is where your and other user's personal directories live. Only put binaries, scripts, or small things in here. Capacity shared with `/work` and `/apps` |
| `/work`    | 20TB           | *quick*    | 500GB | Work is where datasets and large quantities of input/output data is to be stored. Capacity shared with `/home` and `/apps`.                                  |
>[!WARNING]
> Do not put anything you want to keep for longer than a day in `/scratch` as all files are subject to deletion to preserve free space. 

 ## <div style="page-break-after: always;"></div>
## 4: How to use Muscadine

### 4.1: Getting a node allocation

Say you want to build a given program. You could build it on the head, but that can interfere with other people doing the same or running a program on the head. An alternative to that is submitting a Slurm request to get a node for building purposes. Run the following command to reserve a node for a bash terminal.

```bash
srun -c16 --pty bash
```

### 4.2: Available modules

Modules are software stacks such as GCC, Python, OpenBLAS, or ROCM that we provide that are optimized for the cluster its on. A list of all available modules can be seen by running `ml avail`. Here is a table of all the modules provided by default. A few more modules can be made available after loading a compiler like `aocc` or `gcc`. 

```
-------------------- /apps/spack-zen4-v1.0/modulefiles/Core -----------------
   amdblis/5.0       hip/6.2.4          python/3.12.5             rust/1.81.0
   aocc/5.0.0        hipblas/6.2.4      rocblas/6.2.4             sqlite/3.34.1
   apptainer/1.3.4   miopen-hip/6.2.4   rocm-cmake/6.2.4
   contrib/0.1       openmpi/5.0.5      rocm-device-libs/6.2.4
   gcc/14.2.0        python/3.11.9      rocsolver/6.2.4
```

In order to load a module, you can run `ml load <moduleName>`. Tab complete does work with ml and we encourage you use tab complete as it can also list several different versions we provide for each module, most will only have one though.
### <div style="page-break-after: always;"></div>

### 4.3: What do I do if there is a program I want?

The simple answer is to build it from their source repository. The complex answer is to build it from their source repository. We do not install tools or programs for users. That is the user's job of using the cluster. After building a program, you should get a binary executable. If you want to make binaries you make accessible by you anywhere on the system, complete the following steps.

1. After building your binary, create a `.bin` in your home directory by running `mkdir ~/.bin`.
2. Now move that binary into the `.bin` directory.
3. Lastly, you'll need to add the path of that directory to your bash config. NOTE: *You only need to do this once.* Edit `~/.zshrc` adding `export PATH="$PATH:$(HOME)/.bin` to the end.

Users can submit a request to add something they have built to `/apps/contrib` for other users to use as well. 

 ## <div style="page-break-after: always;"></div>
## 5: How to use Slurm

### 5.1: Common Slurm commands

#### 5.1.1: `sinfo`
`sinfo` and is a command that lets you see the cluster status. I have ran `sinfo` on Muscadine during a low usage time so all the nodes are idle. It is *highly* recommended to check this before submitting jobs, specifically greater than half a node in size.
```bash
╭─odh49@muscadine-node-1 ~
╰─$ sinfo
PARTITION  AVAIL  TIMELIMIT  NODES  STATE NODELIST
muscadine*    up   infinite      5   idle muscadine-node-[1-5]
```

#### 5.1.2: `squeue`
`squeue` is a command that allows you to see any current jobs running on the cluster. This is very useful if you want to monitor if your job is running/waiting for resources along with its Job ID. I ran it on Muscadine while I have my meta-8B.sh running.
```bash
╭─odh49@muscadine-node-1 ~
╰─$ squeue
    JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
     3449 muscadine meta-8B.    odh49  R       0:18      1 muscadine-node-2
```

#### 5.1.3: `scancel`
`scancel` kills a Slurm job. This is useful if you realize there was a mistake in your SBATCH file, made a change before it finished, or if it was an interactive job that froze. Here I used the Job ID from my job previously shown to kill the model running.
```bash
╭─odh49@muscadine-node-1 ~
╰─$ scancel 3449
```
#### <div style="page-break-after: always;"></div>
#### 5.1.4: `sacct`
`sacct` is like `squeue` except it shows all Slurm jobs that have been ran, is running, or errored out solely by you. This is very useful when looking at several jobs and seeing how its being handled. Here is the output of `sacct` with a few things running, ran, and failed.
```bash
╭─odh49@muscadine-node-1 ~/Demos/helloWorld
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

#### 5.1.5: `srun`
`srun` is the command you'll use to run a parallel program via Slurm. For the most part, you'll use this within an SBATCH script described in Section 5.3. But if you want an interactive session (eg. `srun -c2 --pty bash`). Using `srun` is also useful when testing code on a small scale before fully implementing the SBATCH for it. Check out https://slurm.schedmd.com/srun.html for a full list of arguments to use with `srun`.
### <div style="page-break-after: always;"></div>


### 5.2: Building a SBATCH script

SBATCH Scripts are what are used by Slurm to better allocate/distribute your program. Below is a template you can use for nearly any Slurm job.

```SBATCH
#!/bin/bash

# Slurm Specific

#SBATCH --job-name="my_name"            #job name
#SBATCH --nodes=1                       #number of nodes
#SBATCH --ntasks-per-node=16            #number of tasks per node
#SBATCH --cpus-per-task=1               #number of physical cores per task
#SBATCH --mem=4G                        #max memory allocated 
#SBATCH --time=0-1:00:00                #max runtime (D-hh:mm:ss)
#SBATCH --output=my_run.log             #output name


# Muscadine Specific

ml load <neededModules>


# Your Application

srun <application>
```

Here is an example of a SBATCH Script used for a Hello World spanning across 2 nodes, 48 threads each, using the openmpi/5.0.5 module, and the binary I made.

```SBATCH
#!/bin/bash

# Slurm Specific

#SBATCH --job-name=helloWorld           #job name
#SBATCH --nodes=2                       #number of nodes
#SBATCH --ntasks-per-node=48            #number of tasks per node
#SBATCH --cpus-per-task=1               #number of cpus per task
#SBATCH --mem=8G                        #max memory allocated
#SBATCH --time=0-1:00:00                #max runtime
#SBATCH --output=helloWorld-%j.out      #output name


# Muscadine Specific

ml load openmpi/5.0.5


# Your Application

srun ./hello_mpi
```

You can submit the SBATCH Script to Slurm via the following command:

```bash
sbatch <sbatchScript>
```

 ## <div style="page-break-after: always;"></div>
## Need Help?

If you have any issues or questions regarding Muscadine, please email Oliver Higginbotham (odh49@msstate.edu) or put questions in the helpdesk-Muscadine thread channel in our SIG-HPC Discord. 

### FAQ
1. 
	Q: What if I don't want to build a program from source?
	A: Womp womp.

2. 
	Q:
	A: