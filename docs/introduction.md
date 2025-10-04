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

### Architecture
Muscadine uses *AMD EPYC Genoa 9454P* running AMD's Zen 4 architecture. This architecture divides the CPU's cores into groups called *core complexes* (CCX) which share L3 cache. CCXs also group into dies called CCDs. CCXs act as NUMA partitions and interface with a I/O Die which handles communication between NUMA partitions and the rest of the system. There are 12 memory controllers for this generation, meaning there are 3 per CCD hardware defined. 

Specifically for Muscadine, there are 6 cores per CCX, 2 CCX per CCD, and 4 CCD per node. Additionally, each memory controller has its own 16GB memory DIMM, so most programs should optimize to the closest memory. Slurm is designed to be NUMA aware and our provided compilers are optimized for our architecture. More information on using architecture aware Slurm submissions, refer to **Advanced Topics → Slurm Tips & Tricks**.

- CPU Specifications: [AMD EPYC™ 9454P](https://www.amd.com/en/products/processors/server/epyc/4th-generation-9004-and-8004-series/amd-epyc-9454p.html)
- Zen 4 White Paper: [Zen 4 White Paper](https://www.amd.com/en/products/processors/server/epyc/4th-generation-architecture.html)

### Benchmarks Leaderboard
Here, we have the students with the highest scores for various cluster benchmarking programs. In order to get your score verified, email your entire config and output file to the current student sysadmin. 
#### Single Node HPL:
- 1st place: Drew Helgerson - 2.405 TeraFlops
- 2nd place: Oliver Higginbotham - 2.371 TeraFlops
- 3rd place:

#### Five Node HPL:
- 1st place: Drew Helgerson - 11.8 TeraFlops
- 2nd place: 
- 3rd place: 

#### MLPerf:
- 1st place:
- 2nd place:
- 3rd place:
