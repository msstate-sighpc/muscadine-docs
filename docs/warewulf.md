# Warewulf

Warewulf is where the majority of configuration will take place on muscadine. warewulf is used to handle the compute node images. all software that can't be made available in the apps tree will need to be present in the compute image.

## Building 

Building warewulf is fairly straightforward, and can be performed by losely following CIQ's docs
the following should be performed in the WW vm discussed on the [main](main.md) page.

### Install Dependencies:

```bash
dnf  --assumeyes  --setopt=install_weak_deps=False  --nodocs  install  dhcp-server  tftp-server  nfs-utils  golang
```

### Mount setup:

to keep the VM small, we'll want to store all of warewulf's installation and source on an NFS mount. this shouldn't affect performance since the connection between VM and host is virtual and is as fast as loopback.

Append the following line to `/etc/fstab`

```/etc/fstab
muscadine-node-1.hpc.msstate.edu:/local/ww                    /opt/warewulf        nfs     defaults,nodev,noatime     0 0
```

now mount it w/

```bash
mkdir /opt/warewulf
mount -a
```
