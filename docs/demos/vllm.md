# vLLM

vLLM is a Large Language Model (LLM) runtime designed for high performance and scalability. It is the industry standard from single-GPU to large-cluster deployments.

## Setup

Muscadine uses AMD Instinct MI210 GPUs. vLLM does not provide pre-built wheels for ROCM, but they do provide containers. We'll be using [Apptainer](/path/to/apptainer.md) to run the container

### Load the `apptainer` LMOD module
```text
module load apptainer
```

### (Optional) Pull the latest container
Provided on Muscadine is a moderately recent version of the vLLM containe located in `/apps/contrib/vllm`. If you wish to run a more recent version of vLLM, you can pull it yourself.

```text
VERSION=$(curl -s https://api.github.com/repos/vllm-project/vllm/releases/latest | jq -r '.tag_name') ; echo $VERSION
SIF_PATH=/scratch/$(id -gn)/$(id -un)/vllm-rocm-$VERSION.sif ; echo $SIF_PATH # Note the path to your image, modify as necessary
apptainer pull $SIF_PATH docker://vllm/vllm-openai-rocm:$VERSION
```

## Choosing a model

Due to Muscadine's hardware, careful consideration must be taken in choosing a model to run. If you are unfamiliar with Muscadine's hardare, read over its [Specifications](../clusters/muscadine.html). The key constraints are as follows:

- `gfx90a` compute architecture: Datatypes are limited to fp64,fp32,fp16,bf16,int64,int32,int8,int4; notably, these GPUs do *not* support any datatypes starting in 'nv' (e.g. nvfp8,nvfp4) nor does it support *some* fp8 models.
- VRAM: Each MI210 contains 64GB of HBM2e memory. While it offers very high bandwidth and low latency, capacity is relatively limited compared to modern offerings.

### A Note on GGUF Quantizations

Shortly after the introduction of his LLM runtime, 'llama.cpp', which greatly increased the amount of hardware capable of running LLMs, Georgi Gerganov created a quantization method and model weight container called 'Georgi Gerganov's Unified Format' or GGUF. These quantizations allowed for much more hardware with less memory to run larger models, however, at sometimes severely decreased performance. vLLM has little-to-no support for GGUF format weights due to the insane amount of development effort required to keep pace with llama.cpp.

### Huggingface

Huggingface (now owned by NVIDIA) is a massive repository for storing open datasets, open weights, and more. It has become the De-Facto place to obtain any open asset at this point.

You can browse available models by navigating to https://huggingface.co/models; there, you can filter by type, parameter count, runtime, and more.

### vLLM Recipes

vLLM maintains a configuration generator or 'recipe' for a variety of popular models; you can browse them at https://recipes.vllm.ai. There, you can choose what GPU, quantization variant, layout strategy, and features you want, and it will generate a `vllm` cmdline

```{note}
The AMD MI210 is an older card, and as such, is not listed as an option in vLLM recipes. Instead, choose the lowest model AMD card available, all will be the same except performance and available memory.
```

Under 'Variant', each option has an associated memory requirement. When hovered, a tooltip appears detailing exactly how it's used. This can be very useful when determining whether a model can run on the available hardware.

## Downloading a model

### Storing Weights

Model weights can become quite large. It's highly discouraged to store them in your home directory (the default). It is recommended to store them in your associated scratch directory (/scratch/group/user). To instruct huggingface to always store weights there, run the following command:

```text
echo "export HF_HOME=/scratch/$(id -gn)/$(id -un)" | tee -a ~/.zshrc
```

### Downloading Weights

By default, vLLM will attempt to download weights if it can't find them, however, it can only do this on node-1. In order to work around this, we pre-fetch weights with the `hf` command.

```text
apptainer exec /apps/contrib/vllm/vllm-openai-rocm_latest.sif \
    hf download \
    <model>
```

Where `<model>` is the user/repo slug located at the top of the model page.

## Running a model

Since we'll use apptainer to run the model, we have to pass a few more cmdline options than indicated by guides or the vLLM recipes.

```{code-block}
:caption: Example
# Request a compute node (note which one you get)
salloc --cpus-per-task 8 --gres gpu:1 

# if you did NOT pull your own container, run the following:
SIF_PATH=/apps/contrib/vllm/vllm-openai-rocm_latest.sif ; echo $SIF_PATH

# if you DID pull your own container, run the following:
SIF_PATH=("/scratch/$(id -gn)/$(id -un)/"vllm-rocm-*.sif([-1])) ; echo $SIF_PATH

# run the model
srun apptainer exec --rocm --add-caps CAP_SYS_PTRACE $SIF_PATH --env TRANSFORMERS_OFFLINE=1 \
    vllm serve Qwen/Qwen3.5-2B \
    --trust-remote-code \
    --tensor-parallel-size 1 \
    --enable-auto-tool-choice \
    --tool-call-parser qwen3_coder \
    --reasoning-parser qwen3
```

```{important}
The `apptainer exec ...` line is requried to use the container, it must not be changed.
The `vllm serve ...` and following lines should be modified to suit the intended model.
```

```{note}
vLLM can take quite a while to launch, just be patient. It may also fail to launch due to inadequate hardware, version compatibilities, or bad commandline options. Do your best to read logs, troubleshoot errors, and if you need help, don't hesitate to submit a Helpdesk ticket on our Discord
```

## Using the model

If you've gotten this far, **Congradulations!**. Now that your model is running, you'll want to inference with it.

vLLM does not provide any interface by itself, you must point a client interface at it's OpenAI or Anthropic compatible API endpoint. Doing so is simple, enter the model configuration for your chosen interface/ui/agent, choose either 'OpenAI compatible endpoint' or 'Anthropic compatible endpoint' and set it to `http://muscadine-node-<X>:8000/v1` where <X> is the node number you were allocated earlier.

While vLLM does not provide an interface, if you wish to graphically interact directly with your model, placeholders have been added to https://muscadine-llm.hpc.msstate.edu for each of the four compute nodes. If your vLLM instance is listening on port 8000 from a compute node, it should automatically be picked up and presented in the UI.