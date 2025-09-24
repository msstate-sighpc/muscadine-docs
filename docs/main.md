# Muscadine Documentation
the included docs exist to instruct someone with a bit of knowledge about clusters but no muscadine-specific knowledge how to bring muscadine up from scratch, should a catastrophy happen or deep update.

## Configuration Files:
all configuration files mentioned in these docs *should* be included in this repo. these should **NOT** be droppped in, but rather used as a reference when following the documentation:

## Starting Point:
before doing anything, it's important to know the starting point these documents assume you are at:

### Hardware:
the following hardware configurations are necessary:

- all U.2 PCIe NVMe Drives should be located in the head node (HBA/JBOD mode, no raid)
- each node should have 2 M.2 NVMe Drives in the rear BOSS.N-1 card sleds
- nodes should be connected to a single, flat network
- ib cards should be connected to a switch in a star topology
- dhcp is required until the ww server is configured
	- after imagine, updates were installed and `/local/patches/os/Rocky-9.4/builds/muscadine/scripts/020-Convert2Cluster` was run

## VM's
In order to meet the needs of a deployment cluster w/ only 1 management node. virtual machines are utilized for certain services. while not necessary, it helps aid management.
- vince's script for creating a vmserver was used but most guides on how to install kvm on redhat should work. 

## NFS
NFS is used for the /apps, /work, /home, and /ww directories.
All NFS storage is provided by the PureStorage Flashblade.
Details on administering it are found here: [Purity//FB](flashblade.md).

## WareWulf
- Warewulf is covered in its own section here: [WareWulf](warewulf.md)

## Slurm
- Slurm is covered in its own section here: [Slurm](slurm.md)

## Spack
- Spack is covered in its own section here: [Spack](spack.md)

## GPUs
- GPU configuration is convered in its own section here: [GPUs](gpu.md)
