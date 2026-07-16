
# Muscadine

```
$$\      $$\                     Welcome to:         $$\$$\
$$$\    $$$ |                                        $$ \__|
$$$$\  $$$$ $$\   $$\ $$$$$$$\ $$$$$$$\$$$$$$\  $$$$$$$ $$\$$$$$$$\  $$$$$$\
$$\$$\$$ $$ $$ |  $$ $$  _____$$  _____\____$$\$$  __$$ $$ $$  __$$\$$  __$$\
$$ \$$$  $$ $$ |  $$ \$$$$$$\ $$ /     $$$$$$$ $$ /  $$ $$ $$ |  $$ $$$$$$$$ |
$$ |\$  /$$ $$ |  $$ |\____$$\$$ |    $$  __$$ $$ |  $$ $$ $$ |  $$ $$   ____|
$$ | \_/ $$ \$$$$$$  $$$$$$$  \$$$$$$$\$$$$$$$ \$$$$$$$ $$ $$ |  $$ \$$$$$$$\
\__|     \__|\______/\_______/ \_______\_______|\_______\__\__|  \__|\_______|
```

Muscadine is MSU Special Interest Group in High Performance Computing (SIG-HPC)'s cluster graciously gifted by Dell to the 2024 GIGADAWGS team. Muscadine's purpose is to be a student development cluster, teaching students at MSU skills in HPC.

---

## Muscadine Specs
### Hardware
#### Compute:
| Node Type       | Cores   | Memory     | GPUs     | Count |
| --------------- | ------- | ---------- | -------- | ----- |
| PowerEdge R7615 | 48 Zen4 | 192GB DDR5 | 1x Mi210 | 5     |

#### Storage:
| Mount      | FileSystem  | Hardware                   | Total Capacity  | Quota | 
| ---------- | ----------- | -------------------------- | --------------- | ----- |
| `/scratch` | BeeGFS      | 5x BOSS-N1 RAID-1 Arrays   | 2.2TB           | None  |
| `/home`    | PureStorage | 6x PureStorage Flashblades | 48TB (96TB raw) | 10GB  |
| `/work`    | PureStorage | 6x PureStorage Flashblades | 48TB (96TB raw) | 500GB |

```{attention}
`/scratch` will be periodically wiped due to limited space. Back up critical data to your `/work` directory.
```

#### Networking:
| Network Type     | Speed     | Latency   | Usecase                                           |
| ---------------- | --------- | --------- | ------------------------------------------------- |
| HDR Infiniband   | 200Gbit/s | 700-900ns | RDMA Storage, Performant Cluster Innerconnect     |
| Gigabit Ethernet | 1Gbit/s   | 170-200μs | NFS Storage, Scheduling, Monitoring, Shell Access |

---

### Advanced Hardware Analysis

#### CPU Architecture
````{sidebar}
*image goes here*
````
Muscadine uses *AMD EPYC Genoa 9454P* running AMD's Zen 4 architecture. This architecture divides the CPU's cores into groups called *core complexes* (CCX) which share L3 cache. CCXs also group into dies called CCDs. CCXs act as NUMA partitions and interface with a I/O Die which handles communication between NUMA partitions and the rest of the system. There are 12 memory controllers for this generation, meaning there are 3 per CCD hardware defined. 

Specifically for Muscadine, there are 6 cores per CCX, 2 CCX per CCD, and 4 CCD per node. Additionally, each memory controller has its own 16GB memory DIMM, so most programs should optimize to the closest memory. Slurm is designed to be NUMA aware and our provided compilers are optimized for our architecture. More information on using architecture aware Slurm submissions, refer to **Advanced Topics → Slurm Tips & Tricks**.

Talk about Zen4 pipeline

*insert pipeline image here*

- CPU Specifications: [AMD EPYC™ 9454P](https://www.amd.com/en/products/processors/server/epyc/4th-generation-9004-and-8004-series/amd-epyc-9454p.html)
- Zen 4 White Paper: [Zen 4 White Paper](https://www.amd.com/en/products/processors/server/epyc/4th-generation-architecture.html)

#### GPU Architecture
````{sidebar}
*gpu image goes here*
````
Muscadine is equipped with a AMD Mi210 48GB Accelerator in each node. 

- GPU Specifications: [AMD Instinct MI210](https://www.amd.com/en/products/accelerators/instinct/mi200/mi210.html)

#### Storage

Muscadine is designed with two storage systems, each with a specific usecase in mind.

---

### Benchmarks Leaderboard
To promote a sense of competition. Here we will host a leaderboard of the best scores of various HPC benchmarks. In order to get your score verified, email your entire config and output file to the current student sysadmin. 

#### HPL

| Rank | Owner               | 1-Node        | 5-Node        | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |
| 1st  | Drew Helgerson      | 19.06 TFlop/s | 104.7 TFlop/s | GPU     |
| 2nd  | Oliver Higginbotham | 2.371 TFlop/s | 11.62 TFlop/s | CPU     |
%%| 1st  | Drew Helgerson      | 2.392 TFlop/s | 11.81 TFlop/s | CPU     |%%

See [Tuning HPL](/adv/hpl.md) to get started

#### MxP-HPL

| Rank | Owner               | 1-Node        | 5-Node        | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |

Nobody has submitted scores for Mxp-HPL

#### HPCg

| Rank | Owner               | 1-Node        | 5-Node        | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |

Nobody has submitted scores for HPCg