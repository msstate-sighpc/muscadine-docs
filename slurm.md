# HPC2 Cluster Slurm Installation Procedure

## Prerequisites:
First we need to install prerequisite software. The following are must-haves, and they must all be available on the Slurm control node AND on the compute nodes:

- Munge
- Hwloc
- Pmix (3.X.X)
- UCX
- Libevent

Specific to Muscadine:
- numa (Epyc 9454P have a numa node per ccx (4))

### Installing HWLOC:

- found here: [https://github.com/open-mpi/hwloc/releases/latest]

`./configure CC=gcc CXX=g++ FC=gfortran --prefix=/apps/hwloc-2.1.0 --enable-netloc --enable-static --enable-shared && make && make install`

### Installing LibEvent:

- found here: [https://github.com/libevent/libevent/releases/latest]

`./configure CC=gcc CXX=g++ FC=gfortran --prefix=/apps/libevent-2.1.11 && make && make check && make install`

### Installing UCX:

- found here: [https://github.com/openucx/ucx/releases/latest/]

`./configure CC=gcc CXX=g++ FC=gfortran --prefix=/apps/ucx-1.7.0 --enable-shared --enable-static && make && make check && make install`

### Installing Munge:

- found here: [https://github.com/dun/munge/releases/latest]

`./bootstrap`
`/configure CC=gcc CXX=g++ FC=gfortran --prefix=/opt/munge-0.5.15 --enable-shared --enable-static --enable-arch=64 --enable-debug && make && make install`

- **Create the munge key:**

`/opt/munge-0.5.15/sbin/mungekey -cv`

- **Link munge -> munge-0.5.15:**

`cd /opt/`
`ln -s munge-0.5.15 munge`

- **Create the socket dir:**

`mkdir -p /opt/munge/var/run/munge`

- **Create the munge service file:**

`cat <<EOF> /etc/systemd/system/munge.service
[Unit]
Description=MUNGE authentication service
Documentation=man:munged(8)
After=network.target
After=time-sync.target

[Service]
Type=forking
EnvironmentFile=-/opt/munge/etc/sysconfig/munge
ExecStart=/opt/munge/sbin/munged $OPTIONS
PIDFile=/opt/munge/var/run/munge/munged.pid
RuntimeDirectory=munge
RuntimeDirectoryMode=0755
User=munge
Group=munge
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF`

- **Edit the launch options:**

`cat <<EOF>>/opt/munge/etc/sysconfig/munge
OPTIONS="--key-file=/opt/munge-0.5.15/etc/munge/munge.key --num-threads=2 --log-file=/var/log/munge.log"
EOF`

- **Copy the service file to /opt/munge/etc so it can be distributed to each node:**

`cp /etc/systemd/system/munge.service /opt/munge/etc/`

- **Change ownership & permissions:**

`chown munge:munge -R /opt/munge-0.5.15`
`chmod g+s,g-w -R /opt/munge-0.5.15`

- **Start the service:**

`systemctl daemon-reload`
`systemctl start munge`
`systemctl enable munge`

### Installing PMIX:

- found here: [https://openpmix.github.io/downloads.html]

`./configure CC=gcc CXX=g++ FC=gfortran \
--prefix=/apps/pmix-3.2.3 \
--enable-shared --enable-static \
--with-hwloc=/apps/hwloc-2.1.0 \
--with-hwloc-libdir=/apps/hwloc-2.1.0/lib \
--with-munge=/opt/munge-0.5.15 \
--with-munge-libdir=/opt/munge-0.5.15/lib \
--with-libevent=/apps/libevent-2.1.11 \
--with-libevent-libdir=/apps/libevent-2.1.11/lib && \
make && make check && make install`

## Installing Slurm[edit]
These steps are executed on the slurm management node as a non-privileged user

- **Load the required modules:**

`module load python`
### Configure Slurm

`./configure CC=gcc CXX=g++ FC=gfortran \
--prefix=/opt/slurm-22.05.6 \
--enable-pam --enable-salloc-kill-cmd \
--with-hwloc=/apps/hwloc-2.1.0 \
--with-pmix=/apps/pmix-3.2.3 \
--with-munge=/opt/munge \
--with-ucx=/apps/ucx-1.7.0`

### Build it

`make`
`make check`
`make install`

### Finish installing all the auth and pmi modules:

`cd contribs/pmi`
`make instxll`
`cd ../pmix`
`make install`
`cd ../perlapi`
`make && make install`
`cd /opt/slurm-22.05.6/lib/ && ln -s ../lib64/perl5 perl`
`cd -`
`cd ../pam`
`sudo make install`
`cd ../pam_slurm_adopt`
`sudo make install`
`cp ../sjstat /opt/slurm-22.05.6/bin/`
`cp ../seff/seff /opt/slurm-22.05.6/bin/`
`cp ../seff/smail /opt/slurm-22.05.6/bin/`

### Install all the extra slurm tools we like

`cd /tmp/`
`unzip Slurm_tools-master.zip`
`cp Slurm_tools-master/partitions/showpartitions /opt/slurm-22.05.6/bin/`
`cp Slurm_tools-master/showuserjobs/showuserjobs /opt/slurm-22.05.6/bin/`

### If internet access

`git clone https://github.com/hl723/seff-array.git`
`cp seff-array/seff-array.py /opt/slurm-21.08.8/bin/seff-array`

### Create slurm/etc dir and transfer service files

`mkdir /opt/slurm-22.05.6/etc`
`cp etc/*.service /opt/slurm-22.05.6/etc/`

### Modify the service files to run out of /opt/slurm

`sed -i 's/opt\/slurm-22.05.6/opt\/slurm/g' /opt/slurm-22.05.6/etc/slurmctld.service`
`sed -i 's/opt\/slurm-22.05.6/opt\/slurm/g' /opt/slurm-22.05.6/etc/slurmdbd.service`
`sed -i 's/opt\/slurm-22.05.6/opt\/slurm/g' /opt/slurm-22.05.6/etc/slurmd.service`
`sed -i 's/opt\/slurm-22.05.6/opt\/slurm/g' /opt/slurm-22.05.6/etc/slurmrestd.service`

### Add the following line to slurmd.service, just above the ExecStart line:

`Environment="SLURMD_OPTIONS=-M --conf-server Hercules-mn-1"`

### Put the config files in place

`cp /opt/slurm/etc/*.conf /opt/slurm-22.05.6/etc/`
`cp -r /opt/slurm/etc/CONF /opt/slurm-22.05.6/etc/`

### Fix ownership and permissions

`chmod g-w -R /opt/slurm-22.05.6`
`chown slurm:slurm -R /opt/slurm-22.05.6`
`chmod 600 /opt/slurm-22.05.6/etc/slurmdbd.conf`

### Stop the old slurmdbd and slurmctld (if upgrading slurm)

`systemctl stop slurmctld`
`systemctl stop slurmdbd`

### Relink to new slurm:

`rm /opt/slurm`
`cd /opt/`
`ln -s slurm-21.08.8 slurm`

### Make the log dir if it doesn't exist

`mkdir -p /var/log/slurm`

## Creating the Slurm Database[edit]
This section assumes we're setting up Slurm for the first time on a cluster. If we're simply upgrading Slurm for a given cluster, this section should be skipped. This section uses hercules as an example case. Change cluster name as needed.

### On mitchell, login as root DB user

`mysql -u root -p`

### Create the slurm database

`CREATE DATABASE adm_hercules_slurm;`

### Switch to that DB

`USE adm_hercules_slurm;`

### Create the slurm DB user (password in pw file)

`CREATE USER 'hercules_slurm'@'hercules-mn-1.hpc.msstate.edu' IDENTIFIED BY 'xxxxx';`
`CREATE USER 'hercules_slurm'@'hercules-mn-2.hpc.msstate.edu' IDENTIFIED BY 'xxxxx';`

### Give permissions

`GRANT ALL PRIVILEGES ON adm_hercules_slurm.* TO 'hercules_slurm'@'hercules-mn-1.hpc.msstate.edu';`
`GRANT ALL PRIVILEGES ON adm_hercules_slurm.* TO 'hercules_slurm'@'hercules-mn-2.hpc.msstate.edu';`

### Now start the slurmdbd on the SlurmDBD host to have slurm set up and start populating the database

`systemctl start slurmdbd`
`systemctl enable slurmdbd`

### Watch the slurmdbd log file to see when it finishes:

`tail -f /var/log/slurm/slurmdbd.log`

## Launching Slurmctld[edit]
On the cluster management node(s):

`cp /opt/slurm/etc/slurmctld.service /etc/systemd/system/`
`systemctl daemon-reload`
`systemctl start slurmctld`
`systemctl enable slurmctld`

## Pushing the Slurm installation to all available nodes[edit]
- **Define the nodelists (using Orion as an example):**

`nodelist=Orion-login-[1-4],Orion-devel-[1-2],Orion-dtn-[1-4],Orion-ood,Orion-[01-25]-[01-72] ood=Orion-ood`

### Load pdsh

`module load pdsh`

### Stop and unlink the existing slurm install on the nodes

`pdsh -w $nodelist -R ssh systemctl stop slurmd`
`pdsh -w $nodelist -R ssh rm /opt/slurm`

### Copy the installation over

`pdsh -w $nodelist -R exec rsync -vaxtHA /opt/slurm-21.08.8 %h:/opt/`
`pdsh -w $nodelist -R exec rsync -vaxtHA /lib64/security/pam_slurm* %h:/lib64/security/`

### Link the new installation and copy service files

`pdsh -w $nodelist -R ssh "cd /opt && ln -s slurm-21.08.8 slurm"`
`pdsh -w $nodelist -R ssh cp /opt/slurm/etc/slurmd.service /etc/systemd/system/`

### Remove the etc directory (for configless install)

`pdsh -w $nodelist -R ssh rm -rf /opt/slurm/etc`

### Start the new slurmds

`pdsh -w $nodelist -R ssh systemctl daemon-reload`
`pdsh -w $nodelist -R ssh systemctl start slurmd`

### Push the etc directory to the OOD nodes, because OOD crashes without it:

`rsync -vaxtHA /opt/slurm/etc $ood:/opt/slurm/`

## Setting up the Initial Slurm Accounts/QOSs/Users[edit]
- **This step assumes we're setting up a fresh slurm database for a new cluster. This step isn't needing if we're just upgrading slurm.:**

### Create the admin account

`sacctmgr --immediate add account admin Cluster=hercules Parent=root`

### Set the qos parameters (assuming using the default 'normal' qos)

`sacctmgr --immediate modify qos normal set Priority=20 Flags=DenyOnLimit UsageFactor=1.000000`

### Allow the admin account to use the configured QOS

`sacctmgr --immediate modify account admin set qos=normal defaultqos=normal`

### Add users to the admin account

`sacctmgr --immediate add user joey Cluster=hercules Account=admin fairshare=parent`
`sacctmgr --immediate add user sesser Cluster=hercules Account=admin fairshare=parent`
`sacctmgr --immediate add user jfrulla Cluster=hercules Account=admin fairshare=parent`
`sacctmgr --immediate add user sanders Cluster=hercules Account=admin fairshare=parent`
`sacctmgr --immediate add user jhrogers Cluster=hercules Account=admin fairshare=parent`

### The above admin users should now be able to submit jobs with:

`#SBATCH -A admin
#SBATCH -p <clustername>
#SBATCH -q normal.05.6/etc/`
