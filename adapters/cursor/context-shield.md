# /context-shield

Apply Context Shield to the current request and workspace.

## Required reference

Read `_lean-context-kit/context-shield-core.md` before taking action. Treat it
as authoritative. If it is missing or unreadable, stop and report the blocker
instead of inventing rules.

## Runtime values

- Reasoning model: `{{REASONING_MODEL}}`
- Reasoning limit: `{{REASONING_LIMIT}}`
- Context model: `{{CONTEXT_MODEL}}`
- Context limit: `{{CONTEXT_LIMIT}}`

Use caller-provided values only. Never replace placeholders with guessed model
names or limits.

## Run

1. Extract the requested outcome, authorized paths, constraints, and the
   verification gate from the request and the core reference.
2. Keep inspection and changes within that scope. Search before bounded reads,
   and use zero-copy briefs through `.agent/WORKER_RULES.md` for delegation.
3. Apply the 60% safe budget, 120-line read cap, terminal cap, three-edit cap,
   `STATE.md` loop ledger, and visual patch-note process.
4. Verify every change with the smallest applicable check.
5. Summarize changed paths, evidence, blockers, and the next action.
