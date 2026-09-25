# Data Transfer

One influential part of HPC is data, Big Data. Large datasets and tons of calculations against those datasets was one of the major reasons HPC was born. This is even more prevalent in a world full of sensors and datapoints. 

There are several ways you can transfer data to Muscadine. These methods include:
- Curl
- Git
- Open OnDemand 
- scp
- rsync

```{note}
All forms of data transfer **must** be done on the head node. These methods will **not** work on any other node.
```

Each of these methods have their own specific usecases. The way they move data will heavily determine which one you'll use for your use case. If you need help moving data, please refer to [Getting Help](../getting-help.md).

---

## Curl

For single files from a http/https source, curl is the best. 

Example use:
```{code-block}
:caption: Terminal
curl -LO <insertLinkHere>
```


## Git

Git also uses http/https but does so for entire repositories. This works for any public git repository or our internal Gitlab instance. 


## Open OnDemand

OOD is the only graphical interface for transfering files. alright...


## scp

SCP is pretty cool


## rsync

Drew really likes rsync...


