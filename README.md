# lean-context-kit

`lean-context-kit` is a portable, low-bloat Agent Workflow and Loop Engineering
Kit for Copilot environments with constrained context windows. The repository
now contains the current Argon v3.1 workflow: one Orchestrator, nine bounded
specialists, `/studio`, `/direction`, and the canonical Studio skill.

## One-tap Copilot integration

### Windows / PowerShell

From the repository root:

```powershell
.\install.ps1 -Workspace .
```

This installs the current workflow at user level and materializes workspace
discovery files under `.github/`. Reload VS Code after installation.

### Git Bash, macOS, or Linux

```bash
./install.sh --workspace .
```

The shell installer supports the same workspace integration and also installs
the existing Cursor and Hermes adapters. Run `./install.sh --help` for options.

The workspace target contains:

```text
.github/
  agents/                  orchestrator + 9 specialists
  prompts/                 studio, direction, and install-copilot prompts
  skills/studio/SKILL.md   canonical autonomous loop
```

That means an agent running from the repository can integrate the workflow with
one command, without manually copying or reconstructing any Markdown files.
The included `/install-copilot` prompt gives Copilot the same one-command
procedure when the repository is already open.

## Current Copilot workflow

```text
Orchestrator
├── builder       engine, gameplay, telemetry, audio
├── designer      UI, HUD, styling, particles, visual juice
├── critic        headless playtest and five-score gate
├── verifier      build, lint, and test verification
├── patch-notes   visual before/after HTML report
├── debugger      difficult root-cause analysis
├── scout         bounded search and mapping
├── reviewer      diff and regression review
└── worker        other bounded tasks
```

All specialists are `user-invocable: false`; only the Orchestrator is the
master agent. `/studio` dispatches Builder or Designer work, runs the Critic,
updates `STATE.md`, and continues without asking between rounds until all five
scores reach 8/10 or a safe stop condition fires. `/direction` records a new
user style direction in `DESIGN.md` and queues implementation tasks.

## Repository architecture

```text
core/                         model-agnostic operating procedures
  context-shield.md           bounded context and verification guide
  studio-loop.md              portable Builder <-> Critic loop
  WORKER_RULES.md             compact zero-copy worker contract
adapters/
  vscode/
    agents/                   current Copilot agent bundle
    prompts/                  current Studio and Direction prompts
    skills/studio/SKILL.md    current Studio skill
  cursor/                     Cursor command templates
  hermes/                     Hermes skill templates
.github/                      workspace-ready Copilot integration
scripts/                      playtest and project bootstrap utilities
install.sh                    cross-platform installer
install.ps1                   native Windows one-tap installer
```

`adapters/vscode/` is the source bundle. `.github/` is a materialized copy for
immediate workspace discovery; rerun the installer after changing the source
bundle so both stay synchronized.

## Configuration

The generic core templates use these placeholders:

```text
{{REASONING_MODEL}}
{{CONTEXT_MODEL}}
{{REASONING_LIMIT}}
{{CONTEXT_LIMIT}}
```

Copy `config.example.env` to `config.env` for local overrides. The current
Copilot adapter intentionally pins the active routing used by this setup:
`gpt-6-studierende` for reasoning agents and `qwen3.8-27b` for context-heavy
specialists. The core procedures remain model-agnostic.

Never commit credentials or private configuration.

## Context Shield

`core/context-shield.md` defines the seven-section operating guide:

- 60% safe working budget
- 120-line text-read cap
- bounded terminal output
- no more than three main-thread edit batches
- zero-copy worker briefs through `.agent/WORKER_RULES.md`
- visual evidence in `docs/patch-notes/`
- durable `STATE.md` checkpoints with a verification gate

## Studio loop

The Studio loop bootstraps a five-tier roadmap:

1. Core loop and telemetry
2. Depth and variety
3. Visual juice and polish
4. Audio, upgrades, and meta-loop
5. UI, accessibility, and release polish

The project must expose `window.__GAME_STATE__` and
`window.__AUTOPLAY__(true)` so the Critic can run deterministic headless
playtests. Visual rounds may run `builder` and `designer` in parallel only when
their file scopes are independent. The Critic captures
`docs/patch-notes/latest-screen.png` and reports evidence for every score below
8.

## Playtesting

```bash
npm install --save-dev playwright
npx playwright install chromium
node scripts/playtest.mjs http://localhost:4173
```

The script enables autoplay, simulates inputs for eight seconds, captures
console and page errors, validates required state keys, and saves the latest
screen.

## Bootstrap another project

```bash
./scripts/ai-init.sh /path/to/project
```

This copies `.agent/WORKER_RULES.md`, the Playwright contract, and a clean
`STATE.md` starter without overwriting an existing state file.
