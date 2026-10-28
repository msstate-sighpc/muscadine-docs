---
title: "Data: What, Where, How?"
subtitle: "Moving, storing, and using data on Muscadine"
author: "SIG-HPC — Thursday, Oct 29, 6:30 PM · Butler 100"
aspectratio: 16-9
lang: en-US
---

## Three questions

- **What** does data actually look like?
- **Where** does it come from, and where does it live?
- **How** do we get it here and *use* it?

HPC is only useful if your data can reach the compute — and get home safely.

::: notes
Framing slide. The announcement: HPC is important for processing large amounts
of data, so tonight we talk about what data actually looks like, where you can
get data from, and how to use that data. Muscadine is our running example, but
the mental models apply to any cluster.
:::

# What does data look like?

## It's not just CSV

- **Structured** — rows & columns: CSV, TSV, Parquet, SQL dumps
- **Semi-structured** — nested trees: JSON, XML, YAML
- **Arrays & tensors** — NetCDF, HDF5, Zarr, .npy
- **Domain formats** — FASTQ (genes), DICOM (images), Shapefile/GeoTIFF (maps)
- **Model weights** — safetensors, PyTorch .pt, GGUF

::: notes
Whatever your field, your data is *somebody else's* domain format. Learn to
recognize the families: tables, trees, arrays, and blobs. The family determines
which tool reads it, how well it compresses, and where it should be stored.
:::

## It has mass

- Data is *heavy* — moving it takes real time
- 1 Gbit/s ≈ 125 MB/s: a **100 GB** dataset ≈ **15 min**; **1 TB** ≈ **2.5 hours**
- Muscadine's compute nodes talk at 200 Gbit/s InfiniBand — the *world* outside does not
- **Bandwidth math is the first calculation of every project**

::: notes
Do the math out loud: dataset size ÷ transfer rate = your afternoon. People
routinely underestimate this by 10x because they think in "download a song"
time, not "download a department's lifetime of measurements" time.
:::

## It comes in pieces

- 100 GB in **one file** streams happily off any filesystem
- 100 GB in **a million small files** grinds metadata to a halt
- Rule of thumb: *bundle the small stuff* — tar, HDF5, Zarr, Parquet datasets
- One exception: never per-file compress on cluster storage (it defeats deduplication)

::: notes
Filesystems spend their lives tracking inodes, not shuffling bytes. A tar of
small files, or an HDF5/Zarr container, is worth hours of wall time. On
Muscadine's PureStorage-backed /work, individual gzip files actually hurt:
the array deduplicates and compresses for you.
:::

# Where does it come from?

## Public data sources

- **Kaggle / Zenodo / figshare** — curated datasets, research artifacts with DOIs
- **Hugging Face Datasets** — NLP, vision, model weights
- **Government**: data.gov, NOAA Climate Data Online, NCBI, USGS EarthData, Census
- **Institutional**: MS State libraries' database subscriptions

::: notes
The hard part is rarely finding data — it's finding data with a license,
format, and provenance you can live with. Zenodo and figshare attach DOIs,
which makes citing your dataset in a paper trivial.
:::

## Three doors into Muscadine

1. **Pull on the head node** — proxy allows `git clone`, `curl`, `wget`,
   `pip install` (in a venv), `apptainer pull`
2. **Push over the VPN** — connect to `vpn.hpc.msstate.edu`, then `scp`/`rsync`
   to `muscadine-node-1`
3. **Upload via Open OnDemand** — `muscadine-ood.hpc.msstate.edu` → Files

::: notes
Muscadine has no direct internet; only the head node faces the ARC network and
HTTP proxy. So: data that a URL can reach comes in door 1; data only you have
comes in door 2 or 3. rsync beats scp for anything big or resumable.
:::

# Where does it live?

## Storage on Muscadine

| Location   | Quota    | For                                          | Lives?            |
|------------|----------|----------------------------------------------|-------------------|
| `/home`    | 10 GB    | scripts, dotfiles, small stuff               | snapshotted       |
| `/work`    | 500 GB   | **datasets**, models, inputs/outputs          | snapshotted       |
| `/scratch` | none     | fast, hot, disposable working data           | **gone. womp womp** |

::: notes
This is the slide to photograph. /home and /work are PureStorage FlashBlade
over NFS; /scratch is BeeGFS across the local NVMe of the compute nodes — the
most performant storage on the cluster, and it is wiped whenever it nears
capacity. "Do not put anything you want to keep for longer than a day in
/scratch."
:::

## When data goes missing

- `/home` and `/work` snapshot **daily at midnight, kept 30 days**
- Recover yesterday's file: `ls /work/.snapshots/`
- `/scratch`: no snapshots. Files are age-wiped automatically
- Your `~/` quota is 10 GB — **datasets belong in `/work/users/<NetID>`**, not your home

::: notes
The .snapshots directory is the closest thing to an undo button we have. It
only holds files older than a day, and it purges after 30 days, so it is a
safety net, not a backup strategy. Critical data also belongs off-cluster.
:::

# How do I use it?

## The dance

1. **Get** — clone/download on the head node into `/work/users/$USER`
2. **Stage** — copy the working subset to `/scratch` at job start
3. **Compute** — run Slurm jobs reading scratch, writing scratch
4. **Preserve** — copy results worth keeping back to `/work` before you log off

::: notes
This four-step loop is the whole job. Stage so the compute reads the fast
filesystem, compute on /scratch where the I/O is free and local, preserve so
the wipe never eats your results. Scripts in /home, data in /work, churn in
/scratch.
:::

## Get it (head node)

``` bash
cd /work/users/$USER

git clone https://github.com/someone/dataset.git
curl -LO https://zenodo.org/record/1234567/files/data.h5

# from your laptop, over the ARC VPN:
rsync -avP ./mydata/ me@muscadine-node-1:/work/users/me/mydata/
```

::: notes
Downloads land in /work, not /home — the quota is 50x bigger and that's what
the space is for. rsync -avP resumes interrupted transfers; on a 100 GB
download that matters.
:::

## Use it (Slurm + OOD)

``` bash
#SBATCH --partition=muscadine
cd /scratch/$USER
cp -r /work/users/$USER/data .
python analyze.py --input data --out results
cp -r results /work/users/$USER/
```

- Or skip the terminal: **Jupyter / VS Code on Open OnDemand** browse `/work` directly

::: notes
A sbatch script that stages, computes, and preserves in that order is the
single highest-leverage habit on a cluster. On the interactive side, OOD's
file manager and Jupyter apps mount the same /work data — no transfer needed
to poke around.
:::

## Pitfalls

- **Head node only** for transfers — don't try to move data from compute nodes
- 2FA every login; SSH tunneling is disabled (use the VPN instead)
- Big job arrays reading thousands of tiny files → bundle first, or you'll own the queue
- Anything not copied to `/work` is **on borrowed time**

::: notes
People ask why scp from a compute node fails: only muscadine-node-1 faces the
network. And if your 1000-task array spends all its time on metadata
lookups, that's the small-files tax from earlier.
:::

# Takeaways

## Cheat sheet

- **What** — know your format and your *volume*; do bandwidth math first
- **Where** — scripts in `/home`, **data in `/work`**, churn in `/scratch`
- **How** — head node pulls, VPN/OnDemand pushes, stage → compute → preserve
- Snapshots save you for 30 days; `/scratch` remembers nothing

## Help

- Docs: <https://msstate.sighpc.com>
- `#helpdesk-muscadine` on the SIG-HPC Discord
- Accounts: help@hpc.msstate.edu

::: notes
Close by pointing at the docs — data-transfer and quick-start pages have these
commands verbatim. Next meeting we can do a live walkthrough of the dance on
Muscadine. Questions?
:::
