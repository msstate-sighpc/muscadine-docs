# Contributing

Students are welcome and encouraged to contribute to the club in many ways, such as documentation, Grafana, or software to be provided in `/apps/contrib`. In any of these cases, please feel free to reach out to one of the members of the executive board.

## Documentation

We provide documentation (you're on it!) that covers general HPC concepts, our Muscadine cluster, available software, software & hardware complexities, etc. If you see an issue with the existing pages or think new pages/topics would be good additions, reach out to be added to our GitLab repository.

```{figure} ../_static/figures/contributing/gitlab.webp
```

## Grafana

An instance of Grafana is currently running on Muscadine's head node to provide graphs and other visualizations on the status of our cluster. If you see an issue with the existing dashboards or think a new dashboard could be made, reach out to be added to Grafana.

```{figure} ../_static/figures/monitoring/grafana-screenshot.png
```

## Software

If you have created or compiled a program that you think would be useful to other people, you may reach out to one of the current student sysadmins about having it added to `/apps/contrib` for it to be accessible by all users.

```{code-block}
:caption: Terminal
╭─<netID>@muscadine-node-1 ~ 
╰─$ ls /apps/contrib 
amd-smi          Fierro     Loci          netcdf-c         texlive
boxocluster      FlowPSI    matar-devel   NeuralGCM        vllm
btop             glibc      modulefiles   paraview         xcompact3d
chameleon-1.3.0  llama.cpp  mpifileutils  rocm-containers
```