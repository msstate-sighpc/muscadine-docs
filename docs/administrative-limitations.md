# Administrative Limitations
## Security
While Muscadine isn't strictly a secure computing resource, it lives in an enterprise secure computing environment. As such, precautions have been taken to protect Muscadine as well as the environment

---

## Networking
Muscadine does not have direct access to the World wide web. All attempts to access the outside web from muscadine or to access muscadine from the worldwide web will be blocked

### Getting Files on Muscadine
Since Muscadine is in a private network, the simplest way to copy a file onto muscadine is to connect to it's network with the HPC2 VPN and `scp` files to it.

First, read to "[**Connecting to the VPN**](user-docs.md#method-two-hpc-vpn)"

Then, run
```bash
scp localfile myuser@muscadine-node-1:/path/to/myfile
```

This should prompt the normal password+duo authentication

### HTTP Proxy
In order to facilitate basic functionally of a modern system, an HTTP proxy is afforded to Muscadine users, this allows users to do things such as:
- `git clone`
- `curl`/`wget`
- `pip install` (in a venv only)
- `apptainer pull`
