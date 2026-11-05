# Available Modules

This page lists the software installed on Muscadine and how to load it. Software is managed with [Lmod](https://lmod.readthedocs.io) environment modules, so you never have to guess a path or set variables by hand.

## Foreword

Much care and consideration goes into curating the site-wide apps tree. Most modules are built with Spack under `/apps/spack-managed`, and the rest are hand-built under `/apps/contrib`. Please do not try to rebuild this software yourself. If something is missing or broken, see [Getting Help](getting-help.md). If you need something that isn't here, see [Building Software with Spack](building-software.md).

## Using Modules

The general workflow looks like this:

1. Find a module
2. Check what it needs
3. Load it
4. Confirm what's loaded

### Find a module

```bash
module avail              # list what's visible right now
module spider <name>      # search everything, including hidden modules
module whatis <name>      # one-line description
```

### Load a module

```bash
module load <name>
module list               # show what is loaded
module purge              # unload everything
```

Run heavy work through Slurm, not on the login node. See [Slurm Basics](./getting-started/slurm-basics.md).

### The module hierarchy

Some modules only appear after you load a compiler and an MPI library. HDF5 is the main example. The order is **compiler, then MPI, then libraries built against both.**

```bash
module load gcc/15.2.0 openmpi/5.0.10
module avail              # hdf5 now shows up
module load hdf5
```

```{note}
If `module avail` doesn't show something you expect, use `module spider <name>`. It tells you exactly what to load first.
```

## Compilers and Languages

| Module | Versions | Notes |
| --- | --- | --- |
| `gcc` | 15.2.0 | GNU C, C++, and Fortran |
| `aocc` | 5.1.0 | AMD optimized C, C++, and Fortran |
| `python` | 3.12.13, **3.14.5** | 3.14.5 is the default |
| `miniconda3` | 24.7.1 | Conda, for custom environments |
| `go` | 1.26.8 | Go compiler and build tools |
| `rust` | 1.92.0 | Rust toolchain (`rustc`, `cargo`) |

```{note}
Newer Python releases often lack prebuilt wheels. If `pip install` fails on 3.14.5, load `python/3.12.13` or use Miniconda.
```

## MPI and Parallel I/O

| Module | Versions | Notes |
| --- | --- | --- |
| `openmpi` | 5.0.10 | Built for `gcc` and `aocc` |
| `mpich` | 5.0.1 | Built for `gcc` and `aocc` |
| `hdf5` | 1.14.6 | Load a compiler and an MPI module first |
| `netcdf-c` | 4.9.3 | C library and tools (`ncdump`, `ncgen`, `nc-config`) for array-oriented scientific data |
| `mpifileutils` | 0.12 | Parallel `dcp`, `dsync`, `drm`, and `dfind` for large datasets. Run inside a Slurm job |

## AMD GPU Stack (ROCm)

Everything GPU-related lives here. The `rocm` module loads the full stack:

```bash
module load rocm/v7.2.3
module list               # check which component versions came in
```

| Component | Versions | Description |
| --- | --- | --- |
| `rocm` | v7.2.3 | Full ROCm software stack |
| `hip` | 7.2.3, **10.0.0** | HIP runtime and kernel language |
| `rocm-cmake` | 7.2.3, **10.0.0** | CMake modules for ROCm builds |
| `rocm-opencl` | 7.2.3, **10.0.0** | OpenCL on ROCm |
| `hipblaslt` | **10.0.0** | Flexible GPU matrix-matrix operations |
| `hipfft` | **10.0.0** | GPU FFT |
| `hiprand` | **10.0.0** | Random number generation interface |
| `hipsparse` | **7.2.3** | Sparse linear algebra |
| `hipcub` | 7.2.3, **10.0.0** | Parallel primitives (CUB port) |
| `rocprim` | 7.2.3, **10.0.0** | Parallel primitives (ROCm-native) |
| `rocrand` | 7.2.3, **10.0.0** | Pseudo and quasi-random number generation |
| `rocthrust` | 7.2.3, **10.0.0** | Parallel algorithms (Thrust port) |
| `kokkos` | 5.1.1, **5.2.2** | C++ performance-portability model |
| `amdsmi` | 7.2.3 | Monitor and control AMD GPUs |
| `rocm-smi-lib` | 7.2.3, **10.0.0** | ROCm SMI library |
| `rocm-bandwidth-test` | 7.2.3 | PCIe and GPU bandwidth tests |
| `rocprofiler-sdk` | 7.2.3, **10.0.0** | Profiling and tracing for GPU applications |
| `rocm-py` | v1.0 | Containerized ROCm tools run through Apptainer. Loads `apptainer` automatically |

Bold is the default version.

```{warning}
`rocm` is v7.2.3, but most components default to **10.0.0**. Loading components without a version can mix the two stacks. Pin versions explicitly:

```bash
module load rocm/v7.2.3 hip/7.2.3 rocrand/7.2.3 rocprim/7.2.3
```

`hipblaslt`, `hipfft`, and `hiprand` only exist as 10.0.0. `hipsparse` only exists as 7.2.3.
```

## CPU Math Libraries

| Module | Versions | Notes |
| --- | --- | --- |
| `amdblis` | 5.3 | AMD optimized BLIS (BLAS) |
| `amdlibflame` | 5.3 | AMD optimized libFLAME (LAPACK-compatible) |

## Containers

| Module | Versions | Notes |
| --- | --- | --- |
| `apptainer` | 1.4.4 | Run containers on the cluster. Use it inside Slurm jobs |

## Scientific Applications

| Module | Versions | Description |
| --- | --- | --- |
| `fierro` | v1.0 | LANL multiphysics code with HIP/ROCm GPU support. See the [Fierro demo] <!-- link --> |
| `loci` | v4.1.3, v4.2.a0 | Parallel C++ framework for numerical simulation. See the [Loci demo] <!-- link --> Builds below. |
| `xcompact3d` | v5.0 | High-order Navier-Stokes solver for turbulence (DNS/LES) |
| `neuralgcm` | v1.0 | Hybrid atmospheric model: differentiable dynamical core plus machine-learned physics |
| `paraview` | v6.0.1 | Parallel scientific visualization |

### Loci builds

Module names encode the build: `loci/<version>-<compiler>-<mpi>-<partitioner>`. Pick the one that matches the MPI you plan to use, and load that MPI module alongside it.

| Module | Compiler | MPI | Partitioner |
| --- | --- | --- | --- |
| `loci/v4.1.3-gcc-openmpi-parmetis` | gcc | Open MPI | ParMETIS |
| `loci/v4.1.3-gcc-openmpi-scotch` | gcc | Open MPI | SCOTCH |
| `loci/v4.1.3-gcc-mpich-parmetis` | gcc | MPICH | ParMETIS |
| `loci/v4.1.3-gcc-mpich-scotch` | gcc | MPICH | SCOTCH |
| `loci/v4.2.a0` | — | — | Development build |

## AI and ML Tools

| Module | Versions | Description |
| --- | --- | --- |
| `llama.cpp` | b6866 | LLM inference in C/C++ for GGUF models on CPU or GPU |
| `opencode` | 1.19.5 | Terminal coding agent locked to the cluster vLLM service |

## Utilities

| Module | Versions | Description |
| --- | --- | --- |
| `ffmpeg` | 8.1 | Audio and video conversion and streaming |
| `sqlite` | 3.53.1 | Embedded SQL database |
| `texlive` | 2026 | TeX Live distribution (`pdflatex`, `xelatex`, `lualatex`, `latexmk`) |
| `btop` | v1.4.7 | Terminal resource monitor |
| `glibc` | v2.43 | Newer GNU C library |

```{warning}
Do not load `glibc` casually. It can break other binaries. It exists for programs that need a newer libc than the system provides, and should only be loaded in a dedicated job script.
```