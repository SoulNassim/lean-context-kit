# lean-context-kit

A small, portable Agent Workflow and Loop Engineering Kit for projects that
must work inside a constrained context window. It keeps shared operating rules
in one core, exposes thin adapters for common agent environments, and uses
verification gates instead of context-heavy narrative.

## Architecture

```text
core/                         shared, model-agnostic procedures
  context-shield.md           bounded context and state workflow
  studio-loop.md              Builder <-> Adversarial Critic loop
  WORKER_RULES.md             compact zero-copy subagent contract
adapters/
  vscode/                     VS Code agent and prompt templates
  cursor/                     Cursor command templates
  hermes/                     Hermes skill templates
scripts/
  playtest.mjs                headless Playwright contract test
  ai-init.sh                  bootstrap another project
templates/STATE.md            clean durable-state starter
install.sh                    build, substitute, and install adapters
```

The core files are the source of truth. Adapters are intentionally thin so the
same loop behaves consistently across environments without skill bloat.

## One-command installation

From the kit root:

```bash
./install.sh
```

On Windows, run it from Git Bash. The installer reads `config.env` when present
and otherwise falls back to `config.example.env`. To customize local values:

```bash
cp config.example.env config.env
./install.sh
```

The private `config.env` is ignored by Git. Override the destination directories
for a smoke test or a managed setup with `VSCODE_USER_PROMPTS_DIR`,
`CURSOR_COMMANDS_DIR`, and `HERMES_SKILLS_DIR`. Unix-like systems use symbolic
links; Windows shells receive copies. The generated `.build/` directory is
ignored and contains the substituted files.

## Runtime placeholders

Markdown templates use only these universal runtime placeholders:

```text
{{REASONING_MODEL}}
{{CONTEXT_MODEL}}
{{REASONING_LIMIT}}
{{CONTEXT_LIMIT}}
```

The example environment file contains sample defaults, but the kit does not
require a particular provider or model. Do not place credentials in
`config.example.env`, prompts, screenshots, or commits.

## Context Shield

`core/context-shield.md` is the operating guide for strict context hygiene:

- Keep active work within a 60% safe working budget.
- Cap individual reads at 120 lines and terminal output with
  `2>&1 | tail -n 30`.
- Keep main-thread edit batches to three or fewer.
- Use zero-copy worker briefs through `.agent/WORKER_RULES.md`.
- Record UI evidence in `docs/patch-notes/`.
- Maintain atomic tasks and a verification gate in `STATE.md`.

The guide is designed to be resumed: a handoff names verified facts, open
risks, and one executable next action instead of copying the whole context.

## Studio: Builder <-> Adversarial Critic

`core/studio-loop.md` defines an autonomous game-building loop:

1. **Phase 0** establishes a five-tier roadmap: core and telemetry, depth and
   variety, visual juice, audio/feedback and meta-loop, then UI/accessibility
   polish. It also requires `window.__GAME_STATE__` with `fps`, `scene`, `score`,
   `playerHp`, `enemies`, `particles`, and `upgrades`, plus
   `window.__AUTOPLAY__(true)` for deterministic checks.
2. **Phase 1** has the Builder implement the smallest verified vertical slice.
3. **Phase 2** runs an endless Builder <-> read-only Adversarial Critic loop.
   The Critic scores Depth / Mechanics, Visual Juice / Polish, Audio / Feedback,
   and Zero-Bug Stability from 1 to 10. Every axis must reach at least 8/10.
   Findings become queued corrective tasks, and the loop continues without
   asking the user between rounds.
4. **Phase 3** runs the release checks and records the final evidence.

The loop stops only when the gate passes, a genuine blocker is recorded, or a
safe context boundary requires a precise checkpoint.

## Playtesting

The headless script expects a running project and the Playwright package:

```bash
npm install --save-dev playwright
npx playwright install chromium
node scripts/playtest.mjs http://localhost:4173
```

It enables autoplay, simulates inputs for eight seconds, captures console and
page errors, validates the required state keys, reads `window.__GAME_STATE__`,
and writes `docs/patch-notes/latest-screen.png`. Set `PLAYTEST_URL` or
`PLAYTEST_SCREENSHOT` to override the defaults.

## Bootstrap another project

```bash
./scripts/ai-init.sh /path/to/project
```

The script copies `.agent/WORKER_RULES.md` and `scripts/playtest.mjs`, and
creates a starter `STATE.md` without overwriting an existing state file.

## Privacy and contribution rules

Review generated files before sharing them. Keep local configuration, generated
builds, worker output, and state ledgers out of the repository unless a project
explicitly wants them. Add shared behavior to `core/`, environment-specific
glue to `adapters/`, and update the smallest relevant verification check.
