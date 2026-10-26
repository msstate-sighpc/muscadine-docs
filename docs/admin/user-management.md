# User Management

### Table of Contents:
- Checking for User Changes
- Looking Up User Details
- Adding Users
- Removing Users

## Checking for User Changes
To check to see if any users are to be added or removed from Muscadine, run the following:

```{code-block}
:caption: Terminal
╭─<netid>@muscadine-node-1 ~
╰─$ /opt/admin/bin/syncaccounts/syncacctusers -c muscadine
user discrepencies on muscadine
--------------------------
users in account DB but not in slurm
--------------------------
abc123
  requestor: Desktop   Muscadine
  justification: Access to Muscadine (SIG-HPC)

users in slurm but not in account DB
--------------------------
```

You can also add the following to your `.bashrc` or `.zshrc` to have it auto-notify you whenever you sign into a new shell:

```bash
/opt/admin/bin/syncaccounts/syncacctusers -c muscadine
echo "use /opt/admin/bin/syncaccounts/syncacctmgt to modify associations"
```

## Looking Up User Details
If you have an ARC workstation, you have access to a few utilities to check user status in `/apps/systools`. These utilities give you very useful information about a user such as whether or not their account is active, if they've completed their training, etc.

You can look up a user by their username:

```{code-block}
:caption: Terminal
╭─<netid>@hpcdc-19429-linux ~
╰─$ /apps/systools/bin/al abc123  # by username
------------------------------------------------------------------------------------
 First Last
     Username  : abc123                           Type       : Ugrad
     Status    : Training Not Complete            Supervisor : John Bradley
     Center    : HPC2                             Email      : abc123@msstate.edu
     Account Types : Non-Funded
                     Muscadine
     Requestor : jbradley
     Requestor Comments:
     Desktop   Muscadine
     General Comments:
     
     Justification:
     Access to Muscadine (SIG-HPC)
```

You can also look up a user by partial full name with the `-f` flag. If there are multiple results, you will be asked to choose which user:

```{code-block}
:caption: Terminal
╭─<netid>@hpcdc-19429-linux ~
╰─$ /apps/systools/bin/al -f first  # by full name
------------------------------------------------------------------------------------
      Username           Name                               Status
------------------------------------------------------------------------------------
   1. (abc123)           First Last                         Active
   2. (def456)           Lirst Fast                         Active
------------------------------------------------------------------------------------
Select a user (0 to abort): 
```

## Adding users
To add new users to Muscadine, you first need enter the `syncacctusers` shell by running `/opt/admin/bin/syncaccounts/syncacctmgt` **as your user**. When you enter the interactive shell, you will see something like the following:

```{code-block}
:caption: Terminal
╭─<netid>@muscadine-node-1 ~
╰─$ /opt/admin/bin/syncaccounts/syncacctmgt 

syncacctmgt
version v2.1.2025.10.16

welcome trg244

using muscadine
interactive mode

(muscadine)>:
```

Within this shell, run the command below to add the new user. Make sure that you change the parameters within `< >` to their correct values.

```bash 
user add <username> <account> <cluster>
```

In the case of Muscadine, account is "sighpc" and cluster is "muscadine"

As an example, if you're adding a user with the NetID `abc123`, your command should look like: `user add abc123 sighpc muscadine`

## Removing users
Removing users is the same process as adding them, just change "add" to "delete". For example, if the user's NetID was `abc123`, you'd run: `user delete abc123 sighpc muscadine`
