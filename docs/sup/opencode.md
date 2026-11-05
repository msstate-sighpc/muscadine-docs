# OpenCode

OpenCode is a terminal-based coding agent. It reads your project, proposes edits, and runs commands on your behalf. On Muscadine it is preconfigured with a system prompt that teaches it how the cluster works.

```{note}
OpenCode runs commands as *you*. It has your permissions and nothing more, but it can still delete your files. Review what it wants to run, and keep work you care about in Git.
```

## Setup

### Load the `opencode` LMOD module

```bash
module load opencode
```

### Verify it loaded

```bash
module list
opencode --version
```

You should see `opencode/1.19.5` in the module list.

### What the module does

Loading the module does two things:

- Makes the `opencode` command available.
- Points OpenCode at the cluster system prompt (`/apps/contrib/opencode/etc/system_prompt.md`) through `OPENCODE_SYSTEM_PROMPT`.

```{important}
The system prompt is set by the module and must not be changed. It tells the agent about Muscadine: use Slurm instead of running heavy work on the login node, use `module load` instead of installing system packages, and where to store data.
```

## Running OpenCode

`cd` into the project you want to work on, then start it:

```bash
cd ~/my-project
opencode
```

OpenCode treats the directory you launch it from as the project root. Start it in the project folder, **not** in `~` or `/scratch`, or it will try to index everything under it.

### Example prompts

- `Explain what main.c does`
- `Write a Slurm batch script that runs ./solver on 2 nodes with 1 GPU each`
- `Why does this build fail?` (paste the error or point it at the log file)

Use it for what it is good at: reading unfamiliar code, writing boilerplate and batch scripts, and explaining build errors.

## Working with Slurm

OpenCode runs on whichever node you start it on. If you are on the login node, **do not** let it run heavy builds or simulations there.

For anything expensive, get a compute node first and run OpenCode there:

```bash
salloc --cpus-per-task 8
module load opencode
opencode
```

```{note}
You can also just have OpenCode *write* the `sbatch` script, then submit it yourself.
```

## Connecting a model

OpenCode needs a model to talk to. On Muscadine you can run your own with vLLM and point OpenCode at it.

### 1. Start a model with vLLM

Follow the [VLLM](../demos/vllm.md) page to start a model on a compute node. Note which node you were allocated, you will need it in the next step.

```{important}
OpenCode needs the model to support **tool calling**. Keep `--enable-auto-tool-choice` and the correct `--tool-call-parser` for your model, as shown on the [VLLM](../demos/vllm) page. Without them, OpenCode can chat but cannot read or edit files.
```

### 2. Write the OpenCode config

In a **second terminal**, create `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "muscadine-vllm/Qwen/Qwen3.5-2B",
  "provider": {
    "muscadine-vllm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Muscadine vLLM",
      "options": {
        "baseURL": "http://muscadine-node-<X>:8000/v1"
      },
      "models": {
        "Qwen/Qwen3.5-2B": {
          "name": "Qwen3.5 2B"
        }
      }
    }
  }
}
```

Replace:

- `<X>` with the node number from step 1.
- `Qwen/Qwen3.5-2B` (in both places) with the exact model name you passed to `vllm serve`.

If you want a config for one project only, save it as `opencode.json` in that project's root instead.

### 3. Launch OpenCode

```bash
module load opencode
cd ~/my-project
opencode
```

Check that OpenCode can see your model:

```bash
opencode models muscadine-vllm
```

If your model is listed, you are connected. If you ever restart vLLM on a different node, update `<X>` in the config.

```{note}
vLLM runs on the compute node you allocated, so OpenCode must be started somewhere that can reach it. The login node and other Muscadine nodes work. Your own laptop does not.
```

## Limitations

- The agent can be wrong. Read what it writes before you run it, especially anything that deletes, moves, or overwrites files.
- Do not paste passwords, private keys, or other secrets into prompts.

## Troubleshooting

**The agent ignores Muscadine conventions**
: Make sure you started it through the module, not from your own copy of the binary. Check with `echo $OPENCODE_SYSTEM_PROMPT`; it should print a path.

**Need help?**
: See [Getting Help](../getting-help.md)