# RKE2

### Table of Contents:
- Head Node
- Compute Node
- Usage

---

## Head Node
### Installation
Run the following installation script in order to install rke2 and rke2-server

```bash
curl -sfL https://get.rke2.io | sh -
```

### Configuration
To configure rke2, you'll want to navigate to `/etc/rancher/rke2/config.yaml`. 

```bash
vim /etc/rancher/rke2/config.yaml
```

We have the current configuration here:
```/etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
```


### Starting RKE2
Enable the service by running the following:

```bash
systemctl enable --now rke2-server.service
```

Lastly, export the utilities for each shell entry. Add the following to the end of your `.bashrc`

```bash
export PATH=$PATH:/var/lib/rancher/rke2/bin/
```

When rke2 runs for the first time, it creates a token at `/var/lib/rancher/rke2/server/node-token`. Read that token and save it somewhere, you'll need it.
```bash
cat /var/lib/rancher/rke2/server/node-token
```

## Compute Node
### Installation
Now the compute nodes will be handled a little different since they are stateless. They only need the rke2-agent to be installed. Additionally, since the image is built within `muscadine-ww`, we must first pull the necessary files using the following bash:

```bash
mkdir /var/tmp/rke2-artifacts && cd /var/tmp/rke2-artifacts/
curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/rke2-images.linux-amd64.tar.zst
curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/rke2.linux-amd64.tar.gz
curl -OLs https://github.com/rancher/rke2/releases/download/v1.33.1%2Brke2r1/sha256sum-amd64.txt
curl -sfL https://get.rke2.io --output install.sh
```

Now, we'll upload these into `muscadine-ww`:
```bash
ssh muscadine-ww "mkdir -p /var/tmp/rke2-artifacts"
scp * muscadine-ww:/var/tmp/rke2-artifacts/
```

Next, we'll ssh into `muscadine-ww`:
```bash 
ssh muscadine-ww
```

Enter the shell of the latest warewulf image while giving it access to the rke2 files:
```bash
wwctl container list
wwctl copy <original-image-name> <new-image-name>
wwctl container exec --bind /var/tmp/rke2-artifacts:/var/tmp/ <new-image-name> /bin/bash
```

Now that we are inside the container, we will run the install script:
```bash
cd /var/tmp
INSTALL_RKE2_ARTIFACT_PATH=/root/rke2-artifacts INSTALL_RKE2_TYPE="agent" sh install.sh
```

### Configuration
After rke2 is installed, enable the service and configure to the head node:
```bash
systemctl enable rke2-agent.service
mkdir -p /etc/rancher/rke2
vim /etc/rancher/rke2/config.yaml
```

```/etc/rancher/rke2/config.yaml
server: https://muscadine-node-1.hpc.msstate.edu:9345
token: <token from server node>
```

Now that rke2 is installed, enabled, and configured, you can exit and build the container.



---

## Usage

### Proxy/HA

### Slinky

### OOD

### OpenWebUI

