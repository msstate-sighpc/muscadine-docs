# Monitoring

Keeping an eye on what your jobs, and the cluster as a whole, are doing is key to using Muscadine well. You can check live node resources interactively with `btop` from a login session, view cluster-wide health and usage on our Grafana dashboards through Open OnDemand, and audit how efficiently an individual Slurm job used its CPU, memory, and GPU allocation with the `jobstats` tool and its per-job Grafana dashboard.

```{toctree}
:maxdepth: 1
:glob:

monitoring
grafana
slurm-monitoring
```
