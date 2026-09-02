# Raspberry Pi 4 Cluster

```{image} ../_static/clusters/pi4/pi4-cluster-1.webp

```

The Pi 4 cluster is a 21-node cluster built for the [GIGADAWGS](/students/index.md) competition team, specifically for the [Single Board Cluster Competition](/students/sbcc.md). It is also used to teach basic cluster concepts on more simple hardware compared to Muscadine.

---

## Pi 4 Cluster Specification

The Pi 4 cluster consists of 21 total nodes, with 1 being a head node and the other 20 being compute nodes. 12 of those compute nodes are also storage nodes, providing distributed storage for benchmarking.

### Hardware:

| Item                                       | Amount | Purpose              |
| ------------------------------------------ | ------ | -------------------- |
| Raspberry Pi 4B 4GB                        | 21     | Compute/Head         |
| NICGIGA 8x2.5GbE 2x10Gb SFP+ switch        | 3      | Interconnect         |
| 2.5GbE USB NIC                             | 21     | Interconnect         |
| 10GbE SFP+ DAC                             | 2      | Cabling              |
| 128GB M.2 SSD                              | 1      | Head Node Storage    |
| SATA Cable USB cable                       | 12     | Cabling              |
| 480GB SATA SSD                             | 12     | Compute Node Storage |
| 1ft Cat6 patch cables                      | 21     | Cabling              |
| USB-A -> USB-C cables                      | 21     | Cabling              |
| USB Charger                                | 5      | Power                |
| Pi 4 cluster enclosure w/ fan              | 5      | Chassis/Cooling      |
| Pi 4 head node enclosure w/ headsink & fan | 1      | Chassis/Cooling      |

### Software:

| Purpose             | Software Name                 |
| ------------------- | ----------------------------- |
| Operating System    | Rocky Linux 9.5, Kernel: 5.14 |
| C/C++ Compiler      | GNU Compiler Collection (GCC) |
| Job Scheduler       | Slurm                         |
| MPI Implementation  | OpenMPI, mpi4py               |
| BLAS Implementation | OpenBLAS                      |
| Package Managment   | RPM, Spack                    |
| Booting System      | Warewulf                      |

### Storage:

The head node has a 128GB SSD for storage, which is used to hold container images for the compute nodes, the Spack tree, and home directories for users of the cluster. The storage nodes have 480GB SSDs each, for a total of around 5.6TB of raw capacity. The storage nodes are used to provide quick, distributed storage for `/scratch`.

| Mount      | Filesystem      | Hardware              | Total Capacity  |
| ---------- | --------------- | --------------------- | --------------- |
| `/scratch` | BeeGFS          | 12x storage node SSDs | 5.6TB           |
| `/home`    | NFS (Head Node) | 1x head node SSD      | 128GB           |
| `/apps`    | NFS (Head Node) | 1x head node SSD      | 128GB           |

### Networking:

| Network Type   | Speed     | Usecase                                                |
| -------------- | --------- | ------------------------------------------------------ |
| 2.5Gb Ethernet | 2.5Gbit/s | NFS & BeeGFS Storage, Scheduling, Cluster Innerconnect |
| 1Gb Ethernet   | 1Gbit/s   | Booting, Shell Access                                  |

---

## Hardware Analysis

The Raspberry Pi 4B model uses the Broadcom BCM2711 SoC, which provides the following:

- CPU: Quad-core ARM Cortex-A72 (64-bit) at 1.5 GHz
- GPU: Broadcom VideoCore VI (32-bit) running at 500MHz
- Memory: 4GB of LPDDR4-2400 SDRAM
- Caches: 32 kB data + 48 kB instruction L1 cache per core; 1 MB L2 cache
