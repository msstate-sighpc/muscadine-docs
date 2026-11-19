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
write-kubeconfig-mode: "0600"
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

```{important}
The kubeconfig file must be `0600` for security, since anyone with access to the file can create, modify, or delete any resource in Kubernetes, including pods, storage, secrets, etc. If you want to access kubectl commands without becoming root, copy the file to your `~/.kube/config` and keep it `0600` so only you can read it, then change your `KUBECONFIG` variable to point to your copy.
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

### KubeVirt

KubeVirt runs full virtual machines as cluster workloads (one QEMU process per VM,
managed through CRDs). It's primary purpose is to run the OOD VM.

#### Installing the operator

```bash
kubectl create namespace kubevirt
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v1.9.1/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/v1.9.1/kubevirt-cr.yaml
```

The CR converges over a few minutes; the install is done when the `kubevirt`
namespace shows the operator, `virt-api`, `virt-controller`, `virt-handler` and
export/template pods all Running:

```bash
kubectl -n kubevirt get pods
```

````{warning}
`virt-handler` crashloops on our nodes with
`Failed to create an inotify watcher: too many open files` (EMFILE) - the distro
default `fs.inotify.max_user_instances=128` is too low for the RKE2 stack. Raise
it and persist on every node, then let the DaemonSet respawn the pod:

```bash
sysctl fs.inotify.max_user_instances=1024
echo 'fs.inotify.max_user_instances=1024' > /etc/sysctl.d/90-kubevirt.conf
kubectl -n kubevirt delete pod <crashed-pod>
```
````

Debugging crashed virt pods needs the previous instance's logs:
`kubectl logs -n kubevirt <pod> --previous`.

#### virtctl

`virtctl` is a client-side executable that makes interacting with KubeVirt much
easier, including power options and serial console access.

```bash
curl -fL -o /usr/local/bin/virtctl \
  https://github.com/kubevirt/kubevirt/releases/download/v1.9.1/virtctl-v1.9.1-linux-amd64
chmod +x /usr/local/bin/virtctl
ln -s /usr/local/bin/virtctl /usr/local/bin/kubectl-virt   # enables `kubectl virt console <vmi>`
```

#### Storage without CDI

Without the CDI operator, images cannot be imported via `DataVolume` HTTP
sources; images and ISOs must be placed into PVCs by hand. Two cluster facts
matter:

- `local-path` is our only StorageClass and is **not marked default**, so
  PVCs must name it explicitly (`storageClassName: local-path`) — otherwise
  they sit `Pending` forever with *unbound immediate PersistentVolumeClaims*.
  We made it the default:

  ```bash
  kubectl patch sc local-path -p \
    '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
  ```

- local-path volumes are **directories** (`/opt/rke2-storage/pvc-<uid>_...`)
  on the head node, claimed `ReadWriteOnce` — each VM stays pinned to the
  node that hosts its volumes.

```{important}
KubeVirt expects the image inside a hand-made PVC volume to be named
**`disk.img`**, if the ISO isn't named this exactly then it will not boot.
```

A PVC is only provisioned once a pod needs it, the easiest way is to make a helper
pod that mounts the ISO volume so it can be copied into storage.

```{code-block} yaml
:caption: iso-helper.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: rocky-iso
spec:
  storageClassName: local-path
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: iso-helper
spec:
  containers:
    - name: sh
      image: alpine
      command: ["sleep", "7200"]
      volumeMounts:
        - name: iso
          mountPath: /iso
  volumes:
    - name: iso
      persistentVolumeClaim:
        claimName: rocky-iso
```

Since we're using `local-path`, we could just `wget` the ISO straight into the
volume's directory under `/opt/rke2-storage`, which can be found with:

```bash
kubectl get pv -o custom-columns=NAME:.metadata.name,CLAIM:.spec.claimRef.name,PATH:.spec.local.path
```

Once we migrate to Longhorn or a different storage backend, then you will have to
copy it a different way.

#### Installing an OS

You're almost certainly going to be doing a regular Rocky Linux install for all
of Muscadine's VMs, so these steps are specific towards that. Adjust as needed
if you're not.

1. Grab a Rocky Linux ISO and put it in a PVC for the VM to use as a CD/DVD
   image. Name it `disk.img` and start the VM. (https://rockylinux.org/download)
2. Start the VM (`kubectl apply` / `kubevirt start`) and log into the console
   (`virtctl vnc name-of-vm --proxy-only --port 5901 --address 0.0.0.0`, then use
   a VNC client to connect)
```{code-block} yaml
:caption: new-vm.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: muscadine-<VM-NAME>-rootdisk
spec:
  storageClassName: local-path
  accessModes: [ReadWriteOnce]
  resources:
    requests:
      storage: 50Gi
---
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  name: muscadine-<VM-NAME>
  labels:
    app: muscadine-<VM-NAME>
spec:
  runStrategy: Manual               # change to RerunOnFailure or Always after installation
  template:
    metadata:
      labels:
        app: muscadine-<VM-NAME>    # this label is what future Services will select
    spec:
      domain:
        cpu:
          cores: 8
        memory:
          guest: 16Gi
        devices:
          disks:
            - name: rootdisk
              bootOrder: 2
              disk:
                bus: virtio
            - name: installer
              bootOrder: 1
              cdrom:
                bus: sata
          interfaces:
            - name: default
              masquerade: {}
      networks:
        - name: default
          pod: {}
      volumes:
        - name: rootdisk
          persistentVolumeClaim:
            claimName: muscadine-<VM-NAME>-rootdisk
        - name: installer
          persistentVolumeClaim:
            claimName: rocky-iso
      terminationGracePeriodSeconds: 180
```
3. In the console, press <kbd>Tab</kbd> to change the kernel command-line options
   for the installer
   - `inst.ks=nfs:192.168.13.43:/patches/os-install/rocky/9.7/rocky.ks`: this
     tells the installer to use the kickstart script from the ARC patches server,
     which makes the VM the same as a regular ARC machine build, including
     configuring LDAP, Duo, SSH, and all required security policies
   - `inst.sshd`: this enables an SSH server during installation, if you want to
     use it instead of VNC for watching the status of the installation (use the
     `tmux a` command to attach to the install log)
   - `SYSTYPE=1  ISSERVER=1  ISVMGUEST=1`: these are passed to the kickstart
     script and change what settings are applied, configs are copied, etc.
4. Once the install is complete, stop the VM, change the VM's `yaml` file to
   remove the ISO mount, then start the VM. Once it's up, you should be able to
   SSH in with your own account information and Duo login.
5. Contact the ARC Helpdesk to have the hostname of the newly created VM added to
   the muscadine-admin sudoers group, that way you are able to use sudo and do
   whatever administrative tasks are required for setting up VM's software.

### Slinky

### OOD

*docs todo*

### OpenWebUI

