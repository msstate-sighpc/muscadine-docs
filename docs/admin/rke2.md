# RKE2

## Table of Contents:
- [Head Node](#head-node)
- [Compute Node](#compute-node)
- [MetalLB](#metallb)
- [Usage](#usage)

---

## Head Node
### Installation
Run the following installation script in order to install rke2 and rke2-server

```bash
curl -sfL https://get.rke2.io | INSTALL_RKE2_METHOD=tar sh -
```

### Configuration
To configure rke2, you'll want to navigate to `/etc/rancher/rke2/config.yaml`. 

```bash
vim /etc/rancher/rke2/config.yaml
```

We have the current configuration here:
```{code-block} yaml
:caption: /etc/rancher/rke2/config.yaml
write-kubeconfig-mode: "0644"
enable-servicelb: false
```

`enable-servicelb` is set to false because RKE2's built-in ServiceLB conflicts with MetalLB, which we run instead (see [MetalLB](#metallb)).

We also need to set the HTTP/HTTPS proxy so that rke2 can pull the images from *da web*.
```bash
vim /usr/local/lib/systemd/system/rke2-server.service
```

```{code-block} ini
:caption: /usr/local/lib/systemd/system/rke2-server.service
Environment='http_proxy=http://dprox.hpc.msstate.edu:3128'
Environment='https_proxy=http://dprox.hpc.msstate.edu:3128'
```

### Starting RKE2
Enable the service by running the following:

```bash
systemctl enable --now rke2-server.service
```

Lastly, export the utilities for each shell entry. Add the following to the end of your `.bashrc`

```bash
export PATH=$PATH:/var/lib/rancher/rke2/bin/
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
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
wwctl container copy <original-image-name> <new-image-name>
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

```{code-block} yaml
:caption: /etc/rancher/rke2/config.yaml
server: https://muscadine-node-1.hpc.msstate.edu:9345
token: <token from server node>
```

Now that rke2 is installed, enabled, and configured, you can exit and build the container.



---

## Usage

### MetalLB

MetalLB gives the cluster a `type: LoadBalancer` implementation: it hands out virtual
IPs from our private IP range and answers ARP for them (layer 2 mode). On Muscadine the pool
is a small section (`192.168.34.192/26`) at the top of our overall range (`192.168.34.0/24`)

#### Disable ServiceLB first

RKE2 ships klipper-based ServiceLB, and running it next to MetalLB causes IP conflicts.
Set `enable-servicelb: false` in `/etc/rancher/rke2/config.yaml` on the head node (as
shown in [Configuration](#configuration)) and restart:

```bash
systemctl restart rke2-server.service
```

The restart bounces the control-plane and kube-proxy. Verify no `svclb-*` pods:

```bash
kubectl get pods -n kube-system | grep svclb
```

#### Install

MetalLB's speaker pods need elevated network permissions, so the namespace must be
labelled for the privileged pod-security profile before install:

```bash
helm repo add metallb https://metallb.github.io/metallb
helm repo update
kubectl create namespace metallb-system
kubectl label namespace metallb-system \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/audit=privileged \
  pod-security.kubernetes.io/warn=privileged \
  --overwrite
helm install metallb metallb/metallb --namespace metallb-system --wait
```

Helm may print `Warning: unrecognized format "cidr"`; it does not affect the install -
the chart deploys fine and pools are configured below, not via values.

#### Address pool and advertisement

Pools and advertisements are configured through MetalLB's CRDs. The manifest lives
in `/apps/other/rke2-images` next to the others:

```{code-block} yaml
:caption: /apps/other/rke2-images/metallb/metallb-config.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: rke2-pool
  namespace: metallb-system
spec:
  addresses:
    - 192.168.34.192/26
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: rke2-l2-advert
  namespace: metallb-system
spec:
  ipAddressPools:
    - rke2-pool
```

```bash
kubectl apply -f metallb-config.yaml
```

```{note}
MetalLB will allocate the first address of the range (`192.168.34.192`, which is
the network address of the /26). To avoid handing that out, replace the CIDR with an
explicit range such as `192.168.34.193-192.168.34.254`. In our case this is fine,
because the network isn't a /26.
```

#### Exposing a service

Give the service a pool annotation and set its type to `LoadBalancer`:

```{code-block} yaml
:caption: example service (muscadine-llm)
apiVersion: v1
kind: Service
metadata:
  name: muscadine-llm
  namespace: default
  annotations:
    metallb.io/address-pool: rke2-pool
spec:
  type: LoadBalancer
  ports:
    - name: http-muscadine-llm
      port: 80
      protocol: TCP
      targetPort: 6767
  selector:
    app: muscadine-llm
```

`kubectl get svc` should then show an `EXTERNAL-IP` from the pool.

#### Verifying

```{warning}
The head node's shell has the HTTP proxy (`dprox.hpc.msstate.edu`) in its environment,
so a plain `curl http://<external-ip>/` gets sent to the proxy, which returns an
`ERR_CONNECT_FAIL` error page. Bypass it with `--noproxy`:
```

```bash
curl --noproxy '*' http://<external-ip>/
```

In the case of vLLM, you'll get a 404 and `{"detail":"Not Found"}`. As long as the
connection made it to the pod and a response came back, MetalLB is working.

### Slinky

### OOD

### OpenWebUI

