# ZFS

the installation of ZFS on muscadine is very straitforward, mostly taken from OpenZFS's wiki for installing ZFS on Linux (ZoL) on redhat [here](https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL-based%20distro/index.html)

- simplified steps are as follow:
	1. ensure epel is installed and configured
	2. install zfs dkms module
	3. create a storage pool
	4. create datasets
		- ensure their mountpoints are correct

## Installation:
since zfs is out-of-tree, it is installed as a dkms module:
```
dnf install -y epel-release
# in the HPC2 rocky image, yum looks for repos in a different path
cp /etc/yum.repos.d/{,HPC2-repos/}epel.repo
dnf install -y kernel-devel
dnf install -y zfs
```

## Configuring ZFS
assuming you have 1 U.2 drive as the boot drive, and the rest for the ZFS pool:

### Identifying disks
- identify the disks you wish to use for zfs by using lsblk: e.g.
```
root@muscadine # lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 894.3G  0 disk 
├─nvme0n1p1 259:11   0 894.2G  0 part 
└─nvme0n1p9 259:12   0     8M  0 part 
nvme3n1     259:1    0 894.3G  0 disk 
├─nvme3n1p1 259:7    0   256M  0 part /boot/efi
├─nvme3n1p2 259:8    0     1G  0 part /boot
├─nvme3n1p3 259:9    0    32G  0 part [SWAP]
└─nvme3n1p4 259:10   0   861G  0 part /
nvme2n1     259:2    0 894.3G  0 disk 
├─nvme2n1p1 259:4    0 894.2G  0 part 
└─nvme2n1p9 259:6    0     8M  0 part 
nvme1n1     259:5    0 447.1G  0 disk 
nvme5n1     259:13   0 894.3G  0 disk 
├─nvme5n1p1 259:14   0 894.2G  0 part 
└─nvme5n1p9 259:15   0     8M  0 part 
nvme4n1     259:16   0 894.3G  0 disk 
├─nvme4n1p1 259:17   0 894.2G  0 part 
└─nvme4n1p9 259:18   0     8M  0 part 
```
- here we can see our boot drive is `/dev/nvme3n1`(easily identified by its mountpoints) and our BOSS.N-1 cards are `/dev/nvme1n1`(identified by the different size)
- we'll use all other drives for our zpool(`/dev/nvme0n1 /dev/nvme2n1 /dev/nvme5n1 /dev/nvme4n1`).
	- don't worry about the device names or UUIDs. while the kernel does change which device names a drive gets on boot, zfs checks each against its own identificaiton system, so the /dev/ path is only important when creating the pool
**NOTE:** since we're not using the drives for anything other than zfs, such as booting, we don't need a partition table. we'll pass the entire drive to zfs

### Creating the Zpool

