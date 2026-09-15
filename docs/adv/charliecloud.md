# Charliecloud Containers

Charliecloud is a lightweight, fully unprivileged, open source container implementation for HPC applications. It can handle the entire container workflow, including building images, pushing/pulling to registries, dealing with accelerators like GPUs.

Unlike traditional container runtimes, Charliecloud leverages Linux user namespaces to execute containers without root privileges, background daemons, or setuid helpers. This simple approach avoids security risks on clusters while maintaining native performance and seamless integration with existing supercomputing workflows.

---

## General Workflow

The standard Charliecloud workflow consists of three stages:

1. **Container Image Creation** (Pull from a registry or build locally)
2. **Convert the Image** (Pack the image into a high-performance archive)
3. **Run Container through Slurm** (Execute interactively or via batch jobs)

---

## 1. Container Image Creation

Charliecloud uses `ch-image` to pull existing container images from standard container image registries or build custom images directly from a Dockerfile.

### Pull an Image from a Registry

You can pull pre-built images from Docker Hub or GitHub Container Registry:

```bash
# Syntax: ch-image pull <registry>/<image>:<tag>
ch-image pull fedora:42
```

### Build an Image from a Dockerfile

If your workflow requires specific dependencies or compilers, you can build an image locally:

```bash
# Syntax: ch-image build -t <image_name> -f <path/to/Dockerfile> <build_context>
ch-image build -t myimage -f Dockerfile .

```

```{tip}
You can list all locally cached images in your Charliecloud storage directory at any time using:
`ch-image list`
```
---

## 2. Convert the Image

Before running an image across cluster compute nodes, use `ch-convert` to export builder storage into a portable runtime format.

* **SquashFS (`.sqfs`) [Recommended]:** Compresses the root filesystem into a single, read-only archive mounted via SquashFUSE. This prevents inode exhaustion and drastically reduces metadata traffic on shared network storage (e.g., Lustre, NFS).
* **Directory (`dir`):** An unpacked filesystem directory. Useful for rapid interactive debugging and testing, but introduces higher metadata load on cluster filesystems.
* **Tarball (`.tar.gz` / `.tar`):** A portable archive suited for cold storage or transferring container images between disparate clusters.

Convert your builder image into a SquashFS archive:

```bash
# Syntax: ch-convert <image_name> <output_filename>.sqfs
ch-convert myimage myimage.sqfs

```

---

## 3. Run Container through Slurm

Charliecloud executes containers using the `ch-run` runtime utility. Under Slurm, containers can run either interactively for debugging or via batch submission scripts for production workloads.

### Interactive Session (`salloc`)

To test code or debug within a containerized shell on a compute node:

```bash
# 1. Request an interactive allocation
salloc -N 1 -n 1 -c 2 --mem=4G -t 01:00:00

# 2. Launch an interactive bash session inside the container
srun --pty ch-run myimage.sqfs -- /bin/bash

```

### Batch Job Submission (`sbatch`)

For unattended batch jobs, wrap `ch-run` inside a standard Slurm submission script:

```bash
#!/bin/bash
#SBATCH --job-name=charliecloud_job
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=8G
#SBATCH --time=02:00:00
#SBATCH --output=%x_%j.out

# Bind host scratch storage and execute the analysis script
srun ch-run -b /scratch/$USER:/scratch myimage.sqfs -- python3 /scratch/run_analysis.py

```

---

## Common `ch-run` Flags

| Flag | Description |
| --- | --- |
| `-b <host>:<container>` | Binds a host path into the container filesystem (e.g., `-b /scratch:/scratch`). |
| `-w` | Launches container with a writable tmpfs overlay (useful for read-only SquashFS images). |
| `--set-env` | Exports host environment variables directly into the container environment. |
| `--join` | Coordinates container ranks across MPI processes to share IPC and shared-memory namespaces. |

```{note}
By default, Charliecloud automatically binds your current working directory, `/tmp`, `/dev`, and `/proc`. Always use the `-b` flag to explicitly mount dedicated scratch or high-speed shared storage spaces when working with large datasets.

```