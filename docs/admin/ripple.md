# Ripple: An Muscadine Agent

### Architecture
- vLLM Service
- Gateway
- Hermes
- OpenWebUI

## vLLM Service

## Gateway

## Hermes

### Apptainer
For now, Muscadine Ripple will use apptainer to host hermes. This will be changed during the Muscadine upgrade to a kubernetes pod

Container build instructions can be found at https://gitlab.hpc.msstate.edu/tah568/arc-agent-containers/hermes/

Currently, only Oliver (odh49) is able to build this container on Muscadine due to subuid assignments.

Running Hermes via apptainer is shown in a systemd file below
```
[Unit]
Description=Ripple Agent Host - Hermes
After=network.target
RequiresMountsFor=/apps

[Service]
WorkingDirectory=/var/tmp/

ExecStart=/apps/spack-managed/core/linux-zen4/apptainer-1.4.4-v673q2qwczpx7c3gsao4f2e733emacvy/bin/apptainer exec \
--env CUSTOM_MODEL_BASE_URL=http://localhost:8180/v1 \
--env CUSTOM_MODEL_NAME=openai/gpt-oss-20b \
--env CUSTOM_MODEL_API_KEY=root@hpc.msstate.edu \
--env API_SERVER_ENABLED=true \
--env API_SERVER_HOST=0.0.0.0 \
--env API_SERVER_PORT=8642 \
--env API_SERVER_KEY='slfgnpsngahngfgg' \
--env API_SERVER_CORS_ORIGINS="*" \
--bind /apps/other/ripple/.hermes:/opt/data \
docker://nousresearch/hermes-agent hermes gateway run

StandardOutput=journal
StandardError=journal

User=llm
Group=llm

LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
```

```{warning}
HERMES SUCKS!!! the API_SERVER_KEY must be at least 16 characters for it to launch the api. There will be ***no*** error and ***no*** warnings. 
```


### Hermes Agent


### 

## OpenWebUI
