# User Management

### Table of Contents:
- Checking for User Changes
- Adding Users
- Removing Users

## Checking for User Changes
To check to see if any users are to be added or removed from muscadine, run the following:

```bash
/opt/admin/bin/syncaccounts/syncacctusers -c muscadine
```

You can also add the following to your `.bashrc` or `.zshrc` to have it auto-notify you whenever you sign into a new shell:

```bash
/opt/admin/bin/syncaccounts/syncacctusers -c muscadine
echo "use /opt/admin/bin/syncaccounts/syncacctmgt to modify associations"
```

## Adding users
To add new users to Muscadine, you first need enter the `syncacctusers` shell by running the following **as your user**:

```bash
/opt/admin/bin/syncaccounts/syncacctusers 
``` 

Now that you are within the `syncacctusers` shell, run the following to add the new user. Make sure that you change the parameters within `< >` to their correct values.

```bash 
user add <username> <account> <cluster>
```

In the case of Muscadine, account is "sighpc" and cluster is "muscadine"

## Removing users
Similar to adding users, the first step is to enter the `syncacctusers` shell by running the following **as your user**:

```bash
/opt/admin/bin/syncaccounts/syncacctusers
```

Now that you are within the `syncacctusers` shell, run the following to remove the user. Make sure that you change the parameters within `< >` to their corre
ct values.

```bash 
user delete <username> <account> <cluster>
```

In the case of Muscadine, account is "sighpc" and cluster is "muscadine"

