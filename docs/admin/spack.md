# Managing Spack
Notes on creating/managing a spack envrionment at HPC{sup}`2`
Initially Conceived June 27, 2024, First Drafted July 8, 2024
Last updated June 4, 2026, by Oliver Higginbotham (odh49)

### Revision History
- v0: July 8, 2024, initial document
- v1: September 5, 2024, updated to include new paths, new config information in section 1
- v2: May 29, 2026, updated to reflect Muscadine's New spack architecture.

### Table of Contents
2. Muscadine's Spack Architecture
3. Maintaining Muscadine's Spack
4. Creating a New Environment
5. Cleaning Up


# Muscadine's Spack Architecture

Spack on Muscadine is made so that all the environments are in the same location, allowing for multiple version of spack to be used simutaniously on the same environments. A tree of spack is shown below:

```spackTree
/apps/
├── spack-managed/
│   ├── core/
│   ├── extras/
│   ├── modulefiles/
│   │   ├──Core/
│   │   ├──EXTRAS/
│   │   └──ROCM/
│   ├── rocm-7.2/
│   └── slurm-dep/
└── other/spack/
    ├── environments/
    │   ├── core
    │   ├── rocm-7.2
    │   ├── extras
    │   └── slurm-dep
    ├── spack/
    └── spack-old/
```
<!--+ Use https://gitlab.com/nfriend/tree-online to generate tree-->

# Maintaining Muscadine's Spack

This part is crucial before doing anything else. All changes revolving around providing software on Muscadine must be done through the swbuild user. The following command will put you into that user.

```bash
sudo su - swbuild
```

## Activating Desired Environment

### Sourcing Spack

This command will show you want spack deployments are avaliable.

```bash
ls /apps/other/spack/
```

This command will allow you to use the specific spack deployment you'd like. Replace "spack-new" with the spack deployment you want to use from the selection shown above.

```bash
. /apps/other/spack/spack-new/share/spack/setup-env.sh
```

### Activating Environment

Now that spack is sourced, you can activate the environment you would like to use/modify. Run the following command to see what environments are avaliable.

```bash
ls /apps/other/spack/environments
```

The following command will activate the environment, replace "ENV" with the environment of your choosing.

```bash
spack env activate /apps/other/spack/environments/ENV
```

## Adding a Package

If a specific package needs to be added, first read the spack info page about the package to determine what variants you need to use. If this errors out, check [Spack Packages](https://packages.spack.io/) to make sure its included in spack.

```bash
spack info packageName
```

Now add the package using the following command:

```bash
spack config edit
```

Within this configurator, you'll edit a few things.

### Modifying Package Definitions

First is adding your package to the package definitions. Near the top of the spack config you'll see a "definitions:" section. Within this there will be a definition including several packages. Add your package in the same manner. An example is shown from the core environment:

```spack.yaml
spack:
  definitions:
  - corePackages:
    - apptainer@1.4.4
    - openmpi@5.0.10
```

As you can see, there are two packages, apptainer and openmpi, you'll add your package to this. Say you want to add python version 3.14.3, the modified definition will look like this:

```spack.yaml
spack:
  definitions:
  - corePackages:
    - apptainer@1.4.4
    - openmpi@5.0.10
    - python@3.14.3
```

### Adding Package Variants

Variants won't always be necessary, but occasionally you'll need to define a particular setting for the package to build with. Reference `spack info packageName` for variant configs. The following will show you how configuring the variants for the package we added in 2.2.1 would go:

```spack.yaml
spack:
  packages:
    python:
      require:
      - None
```

You'll replace "None" with the variant you want to build that package with. If there is actually none, you can ommit it.

## Building New Packages

Before we can build the packages we just added to our config, we must concretize the recipe so spack knows exactly what to do and when.Run the following command to concretize your environment:

```bash
spack concretize
```

Now that the spec tree has been concretized, read over the specs of your packages to make sure everything is what it should be. If all is good, continue forward with building with the following command:

```bash
spack install -j48
```
> [!NOTE]
> Although Muscadine has more than 48 threads, this will optimize core usage and will prevent the system from locking up.

## Updating Modulefiles

Module files are what allows a user to `ml load` software provided by what you built. This is a very intuitive solution for users as these modulefiles adds the software to their path to best suit being used. Now spack already builds them, but we need to make sure they are avaliable.

### Updating from a Pre-existing Environment

Updating from an environment that already has modules is super easy. Just run the following command:

```bash
ml refresh
```

Now if you ran `ml avail` you can see all the avaliable modules to load, check to make sure the new ones are present.

### Updating from a New Environment

If you are updating modulefiles from a new environent, they won't be seen until we've added where the module files are to our module path. First determine where you installed your module files, this will be in your spack config. Next run the following to add them to your module path:

```bash
module use /path/to/modulefiles/
```

Now run `ml refresh` and `ml avail` to see if they were added to your modules. If it didn't work, make sure you have the right path. If it does we can move on to adding it to the profile.d lmod script. To edit this script, run the following:

```bash
vim /etc/profile.d/z030-HPC2-lmod.sh
```

Now navigate to the bottom where you'll see other modulepaths being appended to the module path. Now add the following line to the end of this file:

```bash
export MODULEPATH=$(/apps/other/lmod/lmod/libexec/addto --append MODULEPATH /path/to/modulefiles)
```

Now repeat the steps to verify the change took place properly in a new shell.

# Creating a New Environment

Before continueing this section, make sure you are in the swbuild user and follow Section 2.1.1 on Sourcing Spack.

## Making Environment with Template

### Initial Environment

Although each environment will be different and unique, a template will be provided to assist in the construction of this new environment. But first lets make the environment with the following command, replacing "ENV-NAME" with the desired environment name:

```bash
spack env create /apps/other/environments/ENV-NAME
```

Next activate the environment with the following command:

```bash
spack env activate /apps/other/environments/ENV-NAME
```

### Applying Environment Template

The following command will put you into the configurator for this environment, now copy and paste the template into said configurator.

```bash
spack config edit
```

Spack Environment Template:

```spack.yaml
spack:
  toolchains:
    system:
      - spec: "%c=gcc@11.4.1"
        when: "%c"
      - spec: "%cxx=gcc@11.4.1"
        when: "%cxx"
      - spec: "%fortran=gcc@11.4.1"
        when: "%fortran"
  definitons:
  - packages:
    - pgk1
    - pgk2
  specs:
  - matrix: 
    - [$packages]
    - ["%system"]
  view: false
  concretizer:
    unify: true
  config:
    install_tree:
      root: /apps/spack-managed/ENV_NAME
  modules:
    default:
      roots:
        lmod: /apps/spack-managed/modulefiles/ENV_NAME
        tcl: /apps/spack-managed/modulefiles/ENV_NAME
      enable:
      - lmod
      lmod:
        hash_length: 0
        exclude_implicits: true
        core_compilers:
        - gcc@11.4.1
	hierarchy:
	- mpi
	all:
	  autoload: run
  packages:
    all:
      require:
      - target=zen4

```

Make sure to replace ENV-NAME with your chosen environment name and the packages with the desired packages for this environment.

## Finding Externals

Now that we have a templated environment, we need to let spack know where some things are. Run the following to find the system compiler:

```bash
spack compiler find
```

Next you'll find externals, know that we will have to remove some of these because spack doesn't like them.

```bash
spack external find
```

After it finds the externals, enter the config with `spack config edit` and remove the following entries from the "packages: " section.
- curl
- python
- openssh
- openssl

And just like that, you have a new and functional environment. Now follow Sections 2.2-2.4 on adding, building, and installing said packages.

# Cleaning Up

Do this after any build/install using spack:

```bash
spack gc 
```

- Run the garbage collector after modulefiles, because it should only remove build-dependencies, not runtime. Theoretically.
- Garbage collection is env dependent. so it's somewhat safe to use.

