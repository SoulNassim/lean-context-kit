# /studio

Run the Studio Builder <-> Adversarial Critic loop for the current project.

## Required reference

Read `_lean-context-kit/studio-loop-core.md` before changing files. It is the
source of truth for the five-tier roadmap, runtime hooks, scoring, verification,
and release criteria. If it is missing or unreadable, stop and report the
blocker.

## Runtime values

- Reasoning model: `{{REASONING_MODEL}}`
- Reasoning limit: `{{REASONING_LIMIT}}`
- Context model: `{{CONTEXT_MODEL}}`
- Context limit: `{{CONTEXT_LIMIT}}`

Use caller-provided values only. Never guess a model name or limit.

## Autonomous loop

1. Load the task and `STATE.md`, then select the next ready roadmap task.
2. Run a Builder phase and a separate read-only Adversarial Critic phase.
3. Keep `window.__GAME_STATE__` and `window.__AUTOPLAY__(true)` verifiable.
4. Score Depth / Mechanics, Visual Juice / Polish, Audio / Feedback, and
   Zero-Bug Stability. Queue corrective work for every score below 8/10.
5. Continue automatically without asking between rounds until every score is
   at least 8/10, a safe context boundary is reached, or a genuine blocker is
   recorded. Checkpoint the exact state and next action before handing off.
