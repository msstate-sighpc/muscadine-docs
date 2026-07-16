# Muscadine Quick Start

## Getting a node allocation
Say you want to build a given program. You could build it on the head, but that can interfere with other people doing the same or running a program on the head. An alternative to that is submitting a Slurm request to get a node for building purposes. Run the following command to reserve a node for a bash terminal.

```bash
srun -c16 --pty bash
```

## Available modules
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

## What do I do if there is a program I want?
The simple answer is to build it from their source repository. The complex answer is to build it from their source repository. We do not install tools or programs for users. That is the user's job of using the cluster. After building a program, you should get a binary executable. If you want to make binaries you make accessible by you anywhere on the system, complete the following steps.

1. After building your binary, create a `.bin` in your home directory by running `mkdir ~/.bin`.
2. Now move that binary into the `.bin` directory.
3. Lastly, you'll need to add the path of that directory to your environment.
4. Edit `~/.zshrc` adding `export PATH="$PATH:$(HOME)/.bin` to the end.
```{note}
NOTE: *You only need edit .zshrc once.* 
```

Users can submit a request to add something they have built to `/apps/contrib` for other users to use as well. 