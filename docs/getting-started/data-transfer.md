# Data Transfer

One influential part of HPC is data, Big Data. Large datasets and tons of calculations against those datasets was one of the major reasons HPC was born. This is even more prevalent in a world full of sensors and datapoints. 

There are several ways you can transfer data to Muscadine. These methods include:
- [Curl](data-transfer.html?data-transfer=curl){.external target="_self"}
- [Git](data-transfer.html?data-transfer=git){.external target="_self"}
- [Open OnDemand](data-transfer.html?data-transfer=ood){.external target="_self"}
- [scp](data-transfer.html?data-transfer=scp){.external target="_self"}
- [rsync](data-transfer.html?data-transfer=rsync){.external target="_self"}

```{note}
All forms of data transfer **must** be done on the head node. These methods will **not** work on any other node.
```

Each of these methods have their own specific usecases. The way they move data will heavily determine which one you'll use for your use case. If you need help moving data, please refer to [Getting Help](../getting-help.md) to contact our admins.

---

`````{tab-set}
:sync-group: data-transfer

````{tab-item} Curl
:sync: curl
<br>
<h1>Curl</h1>

Curl is a free and open-source computer program for transferring data to and from Internet servers. For single files from a http/https source, curl is the best. 

Example use:
```{code-block}
:caption: Terminal
cd /work/users/$USER && curl -LO <insertLinkHere>
```
````

````{tab-item} Git
:sync: git
<br>
<h1>Git</h1>

Git also uses http/https, but does so for entire repositories. This works for any publicly hosted git repository including services like Github, Gitlab, and Gitea.

Example use:
```{code-block}
:caption: Terminal
cd /work/users/$USER && git clone <insertRepositoryHTTPLinkHere>
```
````

````{tab-item} OOD
:sync: ood
<br>
<h1>Open OnDemand</h1>

Open OnDemand, or just OOD, is a web-based interface for HPC clusters. OOD is the only supported graphical interface for transferring files to Muscadine.

First navigate to [Muscadine-OOD](https://muscadine-ood.hpc.msstate.edu) and login using your ARC account.

After you are logged in, now you'll hover over the Files tab in the navbar in the top right of the screen. Select the "Home Directory" option. You should now see an interactive page allowing you to upload to or download from your home directory on Muscadine. 
````

````{tab-item} SCP
:sync: scp
<br>
<h1>SCP</h1>

SCP (secure copy) moves files between two machines over SSH. It is the simplest way to push a file from your own computer onto Muscadine, or pull one back down.

As noted above, the Muscadine side of any transfer is always the head node (`muscadine-node-1`). These commands run on your **local machine's** terminal, and from off campus you'll need to be connected to the {ref}`ARC VPN <method-two-arc-vpn>` first. Each transfer will prompt for the usual password + Duo authentication.

Upload a file to Muscadine:
```{code-block}
:caption: Terminal
scp localfile <netid>@muscadine-node-1:/path/on/muscadine
```

Download a file from Muscadine:
```{code-block}
:caption: Terminal
scp <netid>@muscadine-node-1:/path/on/muscadine ./localcopy
```

Add the `-r` flag to copy whole directories instead of single files.
````

````{tab-item} Rsync
:sync: rsync
<br>
<h1>Rsync</h1>

Drew really likes rsync... and for good reason. `rsync` works like `scp` but only transfers the parts of files that are missing or changed, so it is much better for large files and whole directory trees. If a transfer dies halfway (a VPN hiccup, for example), simply run the same command again and rsync will pick up where it left off instead of starting over.

Use it from your **local machine's** terminal, with the VPN connected if you are off campus, just like [scp](data-transfer.html?data-transfer=scp){.external target="_self"} above:

```{code-block}
:caption: Terminal
rsync -avP localdir/ <netid>@muscadine-node-1:/work/users/<netid>/localdir/
```

- `-a` archive mode: copies recursively and preserves permissions and timestamps
- `-v` verbose: shows what is being transferred
- `-P` keeps partial files and shows progress, which is what makes resuming possible

Swap the two paths to pull a directory from Muscadine down to your local machine instead.
````
`````
