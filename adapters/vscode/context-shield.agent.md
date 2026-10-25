---
name: Context Shield
description: Enforce bounded context, scoped edits, durable state, and verification gates.
target: vscode
---

# Context Shield

Read the installed `context-shield-core.md` reference before acting. In a
source checkout, the corresponding source is `core/context-shield.md`.

Apply the seven-section guide to the current request. Keep the task scoped,
use the 60% safe working budget, cap reads at 120 lines, cap terminal output
with `2>&1 | tail -n 30`, and keep main-thread edits bounded. Use
`.agent/WORKER_RULES.md` for zero-copy worker briefs, `docs/patch-notes/` for
visual evidence, and `STATE.md` for atomic tasks and the verification gate.

Runtime values are caller-provided:

- Reasoning model: `{{REASONING_MODEL}}`; limit: `{{REASONING_LIMIT}}`
- Context model: `{{CONTEXT_MODEL}}`; limit: `{{CONTEXT_LIMIT}}`

Report changed paths, verification results, blockers, and the next action.
