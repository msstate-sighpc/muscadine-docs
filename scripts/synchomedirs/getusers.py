import subprocess # type: ignore

def getusers() -> set:
    users = set(subprocess.check_output(['/opt/admin/bin/syncaccounts/syncacctusers','-c','muscadine','-u'],text=True).rstrip().split("\n"))
    if (__name__ == "__main__"):
        print(users)
    return users

if (__name__ == "__main__"):
    getusers()