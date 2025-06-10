# Muscadine Computing Resources are now Live
Muscadine is a 5 node AMD EPYC Genoa system kindly donated to the SCC Team by Dell. This resource is intended to be available to members of the MSU-SIGHPC.

## Getting Access
Access will be given to sighpc users on a case-by-case basis; these requests will be processed weekly. If you'd like to be given access to Muscadine, Please contact [Drew Helgerson](@drewx1126), [John Bradley](@userjack6880), or [Matt Brockhaus](@.zlyme)

The following users have been granted access:
- ads974
- emh585
- is418
- jbradley
- mwb291
- nk599
- odh49
- sesser
- sk2078
- tah568

## Accessing Resources
Please refer to the [HPC2's resources](https://intranet.hpc.msstate.edu/helpdesk/resource-docs/) on connecting to compute resources

### Key differences
Muscadine is a much smaller cluster, and as such, a few things are different including:
- users will sign into `muscadine-node-1.hpc.msstate.edu` rather than a login node
- there are no 'dev' nodes. for software compilation and the like, users will issue a `srun --pty --exclusive bash` to be given a shell on an available node.
- internet access is not provided. Conventional methods of transferring files to the cluster apply. If you need help transferring files to the cluster. [Drew Helgerson](@drewx1126) would be glad to help.

