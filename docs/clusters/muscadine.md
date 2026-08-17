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

## Muscadine Specification
### Compute:
| Node Type       | Cores   | Memory     | GPUs     | Count |
| --------------- | ------- | ---------- | -------- | ----- |
| PowerEdge R7615 | 48 Zen4 | 192GB DDR5 | 1x Mi210 | 5     |

### Storage:
| Mount      | FileSystem  | Hardware                   | Total Capacity  | Quota | 
| ---------- | ----------- | -------------------------- | --------------- | ----- |
| `/scratch` | BeeGFS      | 5x BOSS-N1 RAID-1 Arrays   | 2.2TB           | None  |
| `/home`    | PureStorage | 6x PureStorage Flashblades | 48TB (96TB raw) | 10GB  |
| `/work`    | PureStorage | 6x PureStorage Flashblades | 48TB (96TB raw) | 500GB |

```{warning}
`/scratch` will be periodically wiped due to limited space. Back up critical data to your `/work` directory.
```

### Networking:
| Network Type     | Speed     | Latency   | Usecase                                           |
| ---------------- | --------- | --------- | ------------------------------------------------- |
| HDR Infiniband   | 200Gbit/s | 700-900ns | RDMA Storage, Performant Cluster Innerconnect     |
| Gigabit Ethernet | 1Gbit/s   | 170-200μs | NFS Storage, Scheduling, Monitoring, Shell Access |

---

## Advanced Hardware Analysis

### CPU Architecture
````{sidebar}
```{image} ../_static/clusters/muscadine/muscadine-die.webp
```
````
Muscadine uses *AMD EPYC Genoa 9454P* running AMD's Zen 4 architecture. This architecture divides the CPU's cores into groups called *core complexes* (CCX) which share L3 cache. CCXs also group into dies called CCDs. CCXs act as NUMA partitions and interface with a I/O Die which handles communication between NUMA partitions and the rest of the system. There are 12 memory controllers for this generation, meaning there are 3 per CCD hardware defined. 

Specifically for Muscadine, there are 6 cores per CCX, 2 CCX per CCD, and 4 CCD per node. Additionally, each memory controller has its own 16GB memory DIMM, so most programs should optimize to the closest memory. Slurm is designed to be NUMA aware and our provided compilers are optimized for our architecture. More information on using architecture aware Slurm submissions, refer to **Advanced Topics → Slurm Tips & Tricks**.

Talk about Zen4 pipeline

*insert pipeline image here*

- CPU Specifications: [AMD EPYC™ 9454P](https://www.amd.com/en/products/processors/server/epyc/4th-generation-9004-and-8004-series/amd-epyc-9454p.html)
- Zen 4 White Paper: [Zen 4 White Paper](https://www.amd.com/en/products/processors/server/epyc/4th-generation-architecture.html)

### GPU Architecture
````{sidebar}
```{image} ../_static/clusters/muscadine/mi210-die.jpg
```
````
Muscadine is equipped with a AMD Mi210 64GB Accelerator in each node. This accelerator is based on AMD's CDNA2 architecture, equipped with 64GB of HBM2e, 6,656 stream processors and 104 compute units clocked at 1700 MHz. The AMD Mi210 is excelent at several tasks ranging from physics simulation to AI inference. The table below shows the performance of the GPU at various different precisions (in TFLOPs). 

| FP64 | Matrix FP64 | FP32 | Matrix FP32 | FP16 | BF16 | INT8/INT4 |
| ---- | ----------- | ---- | ----------- | ---- | ---- | --------- |
| 22.6 | 45.3        | 22.6 | 45.3        | 181  | 181  | 181       |

- GPU Specifications: [AMD Instinct MI210](https://www.amd.com/en/products/accelerators/instinct/mi200/mi210.html)

### Storage

You are provided a decently fast and shared home directory. This is the location you start after connecting into Muscadine. You are welcome to keep stuff in your home directory, but there are also `/scratch` and `/work` that you can use.

`/scratch` is build off of the BeeGFS and is the most performant storage solution for Muscadine. The downside is that there is limited storage, thus there will be wipes of old files every now and then whenever it gets near capacity.

`/work` and `/home` are based on the same storage solution so they have the same speed. The difference is that `/work` is intended for project data such as datasets, AI models, output files, etc. If your program intakes data or outputs data, that data should be stored in `/work`.

| Mount      | Total Capacity | Speed      | Quota | Description                                                                                                                                                  |
| ---------- | -------------- | ---------- | ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `/scratch` | 2.2TB          | ***FAST*** | None  | Scratch is to be used for active data or programs that are not vital. ***SCRATCH WILL BE PERIODILY WIPED***                                                  |
| `/home`    | 20TB           | *quick*    | 10GB  | Home is where your and other user's personal directories live. Only put binaries, scripts, or small things in here. Capacity shared with `/work` and `/apps` |
| `/work`    | 20TB           | *quick*    | 500GB | Work is where datasets and large quantities of input/output data is to be stored. Capacity shared with `/home` and `/apps`.                                  |

```{note}
The speeds are intentionally vague. Feel free to benchmark them yourself
```
```{warning}
Do not put anything you want to keep for longer than a day in `/scratch` as all files are subject to deletion to preserve free space. 
```

---

## Benchmarks Leaderboard
To promote a sense of competition. Here we will host a leaderboard of the best scores of various HPC benchmarks. In order to get your score verified, email your entire config and output file to the current student sysadmin. 

### HPL

| Rank | Owner               | 1-Node        | All-Node      | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |
| 1st  | Drew Helgerson      | 19.06 TFlop/s | 104.7 TFlop/s | GPU     |
| 2nd  | Drew Helgerson      | 2.414 TFlop/s | 11.81 TFlop/s | CPU     |
| 3rd  | Oliver Higginbotham | 2.371 TFlop/s | 11.62 TFlop/s | CPU     |

See [Tuning HPL](/adv/hpl.md) to get started

### MxP-HPL

| Rank | Owner               | 1-Node        | All-Node      | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |
| 1st  | Oliver Higginbotham | 135.6 TFlop/s | 648.9 TFlop/s | GPU     |
| 2nd  | Oliver Higginbotham | 10.28 TFlop/s | TFlop/s | CPU |


### HPCg

| Rank | Owner               | 1-Node        | All-Node      | CPU/GPU |
| ---- | ------------------- | ------------- | ------------- | ------- |

Nobody has submitted scores for HPCg
