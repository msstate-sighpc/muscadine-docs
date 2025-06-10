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
gitrepoough is required until the ww server is configured
	- after imagine, updates were installed and `/local/patches/os/Rocky-9.4/builds/muscadine/scripts/020-Convert2Cluster` was run

## VM's
in order to meet the needs of a deployment cluster w/ only 1 management node. virtual machines are utilized for certain services. while not necessary, it helps aid management.
- vince's script for creating a vmserver was used but most guides on how to install kvm on redhat should work. 

## NFS
the end goal is to have the PureStorage Flashblade host all NFS shares for the cluster. currently it's not operational. the remaining U.2 drives in the head node are used to create a zfs pool that is shared over NFS. 
- first create the zpool by folloing this guide: [ZFS](zfs.md)
- once the zfs datasets are created, they can be exported appropriately
modify /etc/exports accordingly:
```/etc/exports
#share home and apps to everything in the muscadine cluster:
/home	192.168.34.0/24(rw,root_squash)
/apps	192.168.34.0/24(rw,no_root_squash)
# note no_root_squash, this is for cluster-wide spack building
# the ww vm has little storage. we want to store the entire warewulf insallation outside of it's image.
/local/ww/ 192.168.34.13(rw,no_root_squash)
we'll use patches for building ww images and such.
/local/patches/ 192.168.34.13(ro,root_squash)
```
- now run `exportfs -a` to make apply the changes

## WareWulf
- Warewulf is covered in its own section here: [WareWulf](warewulf.md)

## Slurm
- Slurm is covered in its own section here: [Slurm](slurm.md)

## Spack
- Spack is covered in its own section here: [Spack](spack.md)

## PureStorage Flashblade
Ideally, in the event of a rebuild, the storage persists from the previous build. However, included is the documentation for the blade as well as configurations needed to initially get it running
- Flashblade is covered in its own section here: [Flashblade](flashblade.md)

gitrepo
