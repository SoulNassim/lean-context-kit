# Agent Integration Guide

This file explains how to install `lean-context-kit` as Copilot agent profiles,
share it with another person, and combine a different Orchestrator provider
with the Uni subagent server.

## What this repository installs

The bundle contains:

- one user-invocable `orchestrator` agent;
- nine internal specialists: `builder`, `critic`, `debugger`, `designer`,
  `patch-notes`, `reviewer`, `scout`, `verifier`, and `worker`;
- the `/studio`, `/direction`, and `/install-copilot` prompts;
- the `studio` skill, which is the canonical autonomous loop;
- workspace copies under `.github/` and user-level copies under the profile
  directories used by the installer.

The specialists use `user-invocable: false`. They are intentionally called by
the Orchestrator instead of appearing as nine extra top-level choices.

## One-tap installation for Copilot

Clone or download the repository, open its root in VS Code, and run one command.

### Windows PowerShell

```powershell
.\install.ps1 -Workspace .
```

### Git Bash, macOS, or Linux

```bash
./install.sh --workspace .
```

The installer:

1. substitutes values from `config.env` or `config.example.env`;
2. installs all agent profiles into the user-level Copilot agent directory;
3. installs `/studio` and `/direction` into the VS Code user prompts folder;
4. installs the `studio` skill;
5. writes workspace-discoverable copies to `.github/agents`,
   `.github/prompts`, and `.github/skills/studio`.

Reload VS Code after installation. From the open repository, Copilot can also
run the `/install-copilot` prompt, which tells it to execute and verify the
same installer. The installer does not overwrite application source files.

## User profiles versus workspace profiles

There are two useful modes:

### User-level profile

Use the installer without a workspace target when the profiles should be
available in every project:

```powershell
.\install.ps1
```

This is the personal installation. It is not committed to the project.

### Workspace profile

Use `-Workspace .` or `--workspace .` when the team should receive the exact
same profiles from Git:

```text
.github/agents/
.github/prompts/
.github/skills/studio/
```

This is the recommended mode for a shared project. The checked-in `.github`
files are the portable contract; the user-level installation is a convenience
for global use.

## How to send it to a friend

### Recommended: invite them to the private GitHub repository

1. Open the repository on GitHub.
2. Go to **Settings -> Collaborators**.
3. Invite their GitHub username.
4. Send them the repository URL.
5. They run:

   ```powershell
   git clone https://github.com/SoulNassim/lean-context-kit.git
   cd lean-context-kit
   .\install.ps1 -Workspace .
   ```

   On macOS/Linux/Git Bash, use `./install.sh --workspace .`.

They need access to the private repository. Do not send your GitHub token or
any API key.

### Alternative: send a release or ZIP

Create a GitHub release or download the repository as a ZIP and send that
archive through a trusted channel. The friend extracts it, opens the folder in
VS Code, and runs the same installer. Do not include `config.env`, generated
`.build/` output, `.agent-out/`, or `STATE.md` from a private project.

### Keep the source synchronized

When the workflow changes, push the repository and have the friend pull again:

```bash
git pull
./install.sh --workspace .
```

On Windows:

```powershell
git pull
.\install.ps1 -Workspace .
```

## Astra Orchestrator plus Uni subagents

This is supported conceptually, but it depends on the host exposing both
providers. The Markdown files are not a provider bridge. They declare:

```text
orchestrator  -> the model selected for orchestrator.agent.md
specialists   -> the model selected in each specialist.agent.md
```

The current bundle routes reasoning-heavy agents to `gpt-6-studierende` and
context-heavy agents to `qwen3.8-27b`. If Astra is the Orchestrator under an
OpenAI provider, and Uni exposes `qwen3.8-27b` through a model/provider that
Copilot can actually call, the split can be:

```text
Astra / OpenAI provider
└── orchestrator
    ├── builder, designer, debugger, reviewer -> gpt-6-studierende or Astra
    └── critic, scout, verifier, patch-notes, worker -> qwen3.8-27b on Uni
```

The exact model IDs must be registered in the Copilot host. `model:` is not a
generic API URL, and `qwen3.8-27b` is not automatically available just because
Uni is running on the network.

Important: the checked-in Orchestrator currently declares
`model: gpt-6-studierende`. Merely selecting Astra in a provider UI does not
rewrite that file. If Astra is the intended Orchestrator, either select it in a
host that overrides the profile model, or make a local copy of
`.github/agents/orchestrator.agent.md` with the exact Astra model ID. Keep the
specialist `model:` values pointed at Uni only if those IDs are available to
the same host.

### What happens at runtime

| Situation | Result |
|---|---|
| Astra and Uni model IDs are both visible to Copilot | Orchestrator and specialists can use their declared routes. |
| Astra is visible but Uni is not | Uni-routed specialists fail to start, or the host asks for a different model; they do not magically reach Uni. |
| The host ignores per-agent `model:` values | Agents run on the host default model; the role workflow still works, but the intended cost/context split is lost. |
| Uni requires an OpenAI-compatible endpoint that Copilot cannot configure | The bundle is installable, but Uni routing needs a Copilot provider/router integration first. |
| The model ID differs, for example `qwen3.8-27b@uni` | Update the relevant specialist frontmatter locally or expose an alias with the exact ID expected by the files. |

### Safe setup procedure

1. Configure Astra as the available Orchestrator model in the Copilot host.
2. Configure Uni as an available provider/model in that same host, gateway, or
   router. Confirm the exact model ID.
3. Keep the Orchestrator's `agents:` list unchanged; it names specialist
   profiles, not providers.
4. Change only the specialist `model:` values that should run on Uni.
5. Install with `-Workspace .` and start with a small test task.
6. Run `/studio` only after a direct specialist invocation or verification task
   confirms that Uni can be reached.

For a local-only provider override, edit the copied files under
`.github/agents/` or the user-level agent directory. Do not edit the source
bundle for one person's endpoint unless the whole team should use it.

## Provider-specific override example

If Uni's registered model ID is `qwen3.8-27b@uni`, change only the affected
profiles:

```yaml
---
name: "critic"
user-invocable: false
model: qwen3.8-27b@uni
---
```

Keep the rest of the profile unchanged. If the host uses a provider selector
separate from the model ID, select Uni in that provider UI instead. If the host
does not support per-agent provider selection, use an OpenAI-compatible gateway
that exposes both Astra and Uni through the model catalog visible to Copilot.

Never commit API keys, private endpoints with embedded credentials, or a
personal `config.env`. The repository's `config.example.env` contains model
defaults only.

## Troubleshooting

- **Only the Orchestrator appears:** this is expected; specialists are hidden
  with `user-invocable: false`.
- **`/studio` is missing:** reload VS Code and confirm the `studio` skill was
  installed; run the installer again.
- **A specialist says model unavailable:** verify the exact model ID and that
  the provider is visible to the Copilot host.
- **The friend sees no agents:** they need to open the cloned repository root
  and reload VS Code after running the installer.
- **Workspace and user copies disagree:** rerun the installer; treat
  `adapters/vscode/` as source and `.github/` as the workspace materialization.
