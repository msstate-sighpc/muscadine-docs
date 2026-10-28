# Quick Start

(requesting-access)=
## Requesting access

To request access to use Muscadine, you will need to fill out [the request form](https://forms.cloud.microsoft/r/8yE6Gk4yFd). You will need to sign in with your MSState account to access the form.

There are some important things to note about requesting access to and using Muscadine:

- **Muscadine is for Students to learn with.**
- Muscadine is not for funded research. If you need compute resources for a funded research project, please speak with your department head regarding Ptolemy access.
- Muscadine is also not for classes. Students may use it to complement their classwork, but official classes will need to request an allocation on Ptolemy.
- Muscadine access is granted until the start of the next year *going forward*. This means you'll have the entire year and through the summer/winter break.
- Muscadine is not guaranteed to be available, but best efforts will be made to make sure it is available.
- To access Muscadine, you must be active within the SIG-HPC community. This means *either* participating in person or through our Discord.
- By using Muscadine, you agree to HPC2/ARC's [Acceptable Use Policy](/_static/external/HPC2-AcceptableUsePolicy.pdf).

Once you have filled out this form, you will receive an email in the next few days with another form to fill out your account details, such as address, date of birth, etc. After this, wait another few days for another email (we love emails) confirming that your account is created. Once it is, proceed to the next section on setting up your account.

## Setting up your ARC account

If this is your first time having an ARC account, you will need to complete a couple of actions before you are able to access ARC resources. Once you have completed your account request form, and you have received the confirmation email, you will have 72 hours to set your password. Note that your ARC account is *different* than your MSState account, therefore it is ***highly encouraged*** to use a different password between the two. Additionally, your ARC password must be changed each year for security purposes. You can change your password on the [Training and Password System](https://taps.hpc.msstate.edu). You will also have to enroll a second Duo account, however you can use the same Duo app on your phone for both MSState and ARC.

After setting your password, you must also complete IT Security and Insider Threat trainings. Conveniently, these are also accessible from the Training and Password System once you have set your password.

(do-your-training)=
```{warning}
If you do not complete the trainings after your account is created, your account will not be active and future requests may be denied.
```

All new accounts will be active for 1 year from creation, and accounts are renewed annually. Reminders will be sent before account expiration if you want to continue using it.

## Accessing Muscadine
### Method One: Titan
First log into Titan at `titan.hpc.msstate.edu`. Use the following template if needed:

```bash
ssh <NetID>@titan.hpc.msstate.edu
```

After entering your ARC password and doing the 2FA push, you can proceed to logging into Muscadine. Muscadine only has one node facing the ARC network which is `muscadine-node-1`, so that is the one we'll want to ssh into. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```
Repeat the authentication process from logging into Titan and you'll be set.

(method-two-arc-vpn)=
### Method Two: ARC VPN

Method Two involves logging into the ARC VPN. Go to [https://servicedesk.its.msstate.edu](https://servicedesk.its.msstate.edu/TDClient/45/Portal/KB/?CategoryID=80) and download the Cisco AnyConnect VPN by following ITS's guide. Once that is completed, launch the VPN and connect to `vpn.hpc.msstate.edu`. It will then ask for your Group (HPC2), Username (your NetID), Password (your ARC Password), and Duo 2FA Passcode (get from duo app or enter 'push' to recieve a push challenge notification). Once you are connected, you can ssh directly into muscadine's head node `muscadine-node-1`. Use the following template if needed:

```bash
ssh <NetID>@muscadine-node-1.hpc.msstate.edu
```

---

## Muscadine's Storage
You are provided a decently fast and shared home directory. This is the location you start after connecting into Muscadine. You are welcome to keep stuff in your home directory, but there are also `/scratch` and `/work` that you can use.

`/scratch` is built off of BeeGFS and is the most performant storage solution for Muscadine. The downside is that there is limited storage, thus there will be wipes of old files every now and then whenever it gets near capacity.

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

## Using an HPC System
### Getting a node allocation
Say you want to build a given program. You could build it on the head, but that can interfere with other people doing the same or running a program on the head. An alternative to that is submitting a Slurm request to get a node for building purposes. Run the following command to reserve a node for a bash terminal.

```bash
srun -c16 --pty bash
```

### Available modules
Modules are software stacks such as GCC, Python, OpenBLAS, or ROCM that we provide that are optimized for the cluster its on. A list of all available modules can be seen by running `ml avail`. Here is a table of all the modules provided by default. A few more modules can be made available after loading a compiler like `aocc` or `gcc`. 

```
-------------------- /apps/spack-zen4-v1.0/modulefiles/Core -----------------
   amdblis/5.0       hip/6.2.4          python/3.12.5             rust/1.81.0
   aocc/5.0.0        hipblas/6.2.4      rocblas/6.2.4             sqlite/3.34.1
   apptainer/1.3.4   miopen-hip/6.2.4   rocm-cmake/6.2.4
   contrib/0.1       openmpi/5.0.5      rocm-device-libs/6.2.4
   gcc/14.2.0        python/3.11.9      rocsolver/6.2.4
```
```{note}
This may not be an accurate list of currently avaliable modules, run `ml avail` to get the system specific module list.
```

In order to load a module, you can run `ml load <moduleName>`. Tab complete does work with ml and we encourage you use tab complete as it can also list several different versions we provide for each module, most will only have one though.

### What do I do if there is a program I want?
The simple answer is to build it from their source repository. The complex answer is to build it from their source repository. We do not install tools or programs for users. That is the user's job of using the cluster. After building a program, you should get a binary executable. If you want to make binaries you make accessible by you anywhere on the system, complete the following steps.

1. After building your binary, create a `.bin` in your home directory by running `mkdir ~/.bin`.
2. Now move that binary into the `.bin` directory.
3. Lastly, you'll need to add the path of that directory to your environment.
4. Edit `~/.zshrc` adding `export PATH="$PATH:$(HOME)/.bin` to the end.
```{note}
NOTE: *You only need edit .zshrc once.* 
```

Users can submit a request to add something they have built to `/apps/contrib` for other users to use as well. 

