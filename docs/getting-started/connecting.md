# Connecting to the Cluster

`````{tab-set}
:sync-group: access

````{tab-item} Method One: Titan
:sync: titan

## Method One: Titan
First log into Titan at `titan.hpc.msstate.edu`. Use the following template if needed:

```bash
ssh <NetID>@titan.hpc.msstate.edu
```

After entering your HPC password and doing the 2FA push, you can proceed to logging into Muscadine. Muscadine only has one node facing the HPCC network which is `muscadine-node-1`, so that is the one we'll want to ssh into. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```

Repeat the authentication process from logging into Titan and you'll be set.
````

````{tab-item} Method Two: HPC VPN
:sync: vpn

## Method Two: HPC VPN
Method Two involves logging into the HPC{sup}`2` VPN. Go to [https://servicedesk.its.msstate.edu](https://servicedesk.its.msstate.edu/TDClient/45/Portal/KB/?CategoryID=80) and download the Cisco AnyConnect VPN by following ITS's guide. Once that is completed, launch the VPN and connect to `vpn.hpc.msstate.edu`. It will then ask for your Group (HPC2), Username (your NetID), Password (your HPC Password), and Duo 2FA Passcode (get from duo app or enter 'push' to recieve a push challenge notification). Once you are connected, you can ssh directly into muscadine's head node `muscadine-node-1`. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```
````
`````