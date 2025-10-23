# OpenOnDemand

**Open OnDemand** is a web-based interface developed by the Ohio Supercomputer Center that provides users with easy, browser-based access to high-performance computing (HPC) resources. Instead of requiring command-line interaction over SSH, Open OnDemand lets users manage jobs, transfer files, and even launch graphical applications directly through a web browser.

OOD integrates with existing HPC systems — including Slurm — to provide a user-friendly layer on top of the cluster’s infrastructure. Users can:

- Submit, monitor, and manage jobs via a graphical job composer.
- Upload, download, and edit files using a built-in file manager.
- Open interactive sessions for remote desktops, Jupyter notebooks, RStudio, and other GUI tools.
- View cluster usage and job queue information in real time.

---

## Using OOD
### Connecting to OOD

To use OOD, you must first be able to access Muscadine. Read "[**Connecting to the VPN**](/user-docs.md#method-two-hpc-vpn)"

Once Connected, open a web browser and navigate to https://muscadine-node-1.hpc.msstate.edu/

### Launching an Interactive App

OOD has a many features such as GUI-based file browsing, a built-in terminal, and more. The primary purpose of OOD, however, is to launch interactive apps.

1. Click "Interactive Apps" in the top bar
2. Choose an app to launch. See [Current Apps](#current-apps) for which ones are available.
3. Complete the form with the desired values. Defaults have been selected for each app and are usually ideal. only change these values should you need to.
4. Click Launch
5. Once the app has finished spinning up, a "Connect to X" button will appear in the bottom of its entry card; click it.

### Viewing Existing Apps

A log of recent apps is kept both to allow users to reconnect to a still-running app or to view logs for apps. You can view these by clicking the button just to the right of "Interactive Apps" in the top bar.

Some things you can do in this view
- View Previous jobs
- Delete jobs. (Delete a running job will end it prematurely)
- Connect to running jobs
- View output files of current and past jobs. (Click the Session id to expand these)

---

## Current Apps
### Jupyter Lab
Jupyter lab is an interactive juniper, python, and R runtime where users can add, modify, and run snippets of code in real-time. this is incredibly useful for demonstration and debugging.

### VSCode
VSCode is a lightweight, open-source IDE developed by Microsoft. This instance runs in your browser for portability.

### Remote Desktop
OOD has support for running an entire desktop environment within a slurm job. This currently isn't functional on muscadine.
```{important}
Attempting to launch a desktop interactive app will fail. Kindly refrain.
```