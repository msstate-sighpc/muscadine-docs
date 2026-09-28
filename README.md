# Muscadine Documentation Source Repository

```
$$\      $$\                     Welcome to:         $$\$$\
$$$\    $$$ |                                        $$ \__|
$$$$\  $$$$ $$\   $$\ $$$$$$$\ $$$$$$$\$$$$$$\  $$$$$$$ $$\$$$$$$$\  $$$$$$\
$$\$$\$$ $$ $$ |  $$ $$  _____$$  _____\____$$\$$  __$$ $$ $$  __$$\$$  __$$\
$$ \$$$  $$ $$ |  $$ \$$$$$$\ $$ /     $$$$$$$ $$ /  $$ $$ $$ |  $$ $$$$$$$$ |
$$ |\$  /$$ $$ |  $$ |\____$$\$$ |    $$  __$$ $$ |  $$ $$ $$ |  $$ $$   ____|
$$ | \_/ $$ \$$$$$$  $$$$$$$  \$$$$$$$\$$$$$$$ \$$$$$$$ $$ $$ |  $$ \$$$$$$$\
\__|     \__|\______/\_______/ \_______\_______|\_______\__\__|  \__|\_______|
```

## Building

This repo is designed to be built with Shibuya Sphinx theme. Steps are as follows


### For HPC Workstations:
```bash
# Load Python 3
ml python

# Recommended: create a venv
python -m venv /var/tmp/sphinx
. /var/tmp/sphinx/bin/activate

# Install requirements
pip install -r requirements.txt

# Build docs
make html

# Change directory to build
cd build/html/

# Host local html server
python -m http.server 8080

# Open local site
firefox http://localhost:8080
```

### For personal machines:
```bash
# Recommended: create a venv
python -m venv /var/tmp/sphinx
. /var/tmp/sphinx/bin/activate

# Install requirements
pip install -r requirements.txt

# Build docs
make html
```

## CI/CD

This repository uses github workflows for automatic building. Contributions to this site will automatically be built and pushed to the site at https://msstate.sighpc.com
