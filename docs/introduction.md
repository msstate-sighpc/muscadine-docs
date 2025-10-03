# Introduction
Muscadine is MSU's Special Interest Group in High Performance Computing (SIG-HPC) cluster gifted to MSU by Dell for our 2024 GIGADAWGS team. Muscadine is currently operating as a student development cluster, being used to teach students at MSU skills in HPC.

## Muscadine Specs
### Hardware
#### Compute:
- 5x Nodes:
	- 1x AMD EPYC Genoa 9454P 48 core CPU
	- 12x 16 GB DDR5 4800MT/s (192GB total)
	- 1x Nvidia/Mellanox HDR 200Gbit/s HCA
	- 1x AMD Radeon Instinct MI210 (64GB) GPU

#### Storage:
- BeeGFS
	- 5x BOSS-N1 RAID-1 Arrays
	- mounted on `/scratch`
	- 2.2TB Distributed Filesystem
- PureStorage Flashblade
	- Clustered flash array
	- 6 16TB blades for 96TB raw storage
	- mounted on `/home`, `/work`, and `/apps`
	- 48TB usable space (w/ 100% redundancy)

#### Networking:
- HDR Infiniband Switch
	- 24x HDR ports
	- Used for:
		- Performant Cluster Communication
		- RDMA BeeGFS
- Gigabit Switch
	- 48x Gigabit ports
	- Provides admin and cluster management

### Benchmarks Leaderboard
Here, we have the students with the highest scores for various cluster benchmarking programs. In order to get your score verified, email your entire config and output file to the current student sysadmin.

#### High-Performance Linpack (5-node):
- 1st place: Drew Helgerson - 11.8 TeraFlops
- 2nd place: 
- 3rd place:

#### High-Performance Linpack (single node):
- 1st place: Drew Helgerson - 2.405 TeraFlops
- 2nd place: Oliver Higginbotham - 2.371 TeraFlops
- 3rd place: 

#### MLPerf:
- 1st place:
- 2nd place:
- 3rd place:
