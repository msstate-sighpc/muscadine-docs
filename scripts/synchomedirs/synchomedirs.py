import os,shutil,sys
from pwd import getpwnam
from grp import getgrgid

from getusers import getusers

try:
    if sys.argv[1] == "write":
        write = True
        print( "writing changes:" )
except:
    write = False
    print( "dry run:" )

muscadineHome = "/home"
muscadineScratch = "/scratch"
muscadineWork = "/work"
muscadineSkel = "/etc/skel"

# # assume we query for homedir users and parse into this list
# homedirusers = { 'tah568','jbradley','emh585','testuser'}

# submodule to get users from john's script
homedirusers = getusers()

print("The following directories were created:")
for user in homedirusers:
    try:
        uid = getpwnam(user).pw_uid
        gid = getpwnam(user).pw_gid
        group = getgrgid(gid).gr_name
    except Exception as e:
        print(f"Error getting info for {user}: {e}")
        continue

    usersHomeDir = f"{muscadineHome}/{user}"
    usersScratchDir = f"{muscadineScratch}/{group}/{user}"
    usersWorkDir = f"{muscadineWork}/users/{user}"

    if (not os.path.exists(usersHomeDir)):
        print(usersHomeDir,uid,gid)
        if write:
            shutil.copytree(muscadineSkel,usersHomeDir)
            os.chown(usersHomeDir,uid,gid)
            os.chmod(usersHomeDir,0o750)
        
    if (not os.path.exists(usersScratchDir)):
        print(usersScratchDir,uid,gid)
        if write:
            os.makedirs(usersScratchDir,exist_ok=True)
            os.chown(usersScratchDir,uid,gid)
            os.chmod(usersScratchDir,0o750)

    if (not os.path.exists(usersWorkDir)):
        print(usersWorkDir,uid,gid)
        if write:
            os.makedirs(usersWorkDir,exist_ok=True)
            os.chown(usersWorkDir,uid,gid)
            os.chmod(usersWorkDir,0o700)
