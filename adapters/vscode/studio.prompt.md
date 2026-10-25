---
name: Studio
description: Run the autonomous Builder and Adversarial Critic game loop.
agent: "Context Shield"
---

# Studio

Read the installed `studio-loop-core.md` reference before acting. In a source
checkout, the corresponding source is `core/studio-loop.md`.

Run Phase 0's five-tier roadmap, expose `window.__GAME_STATE__` and
`window.__AUTOPLAY__(true)`, then execute the Builder <-> Adversarial Critic
loop. Score Depth / Mechanics, Visual Juice / Polish, Audio / Feedback, and
Zero-Bug Stability. Continue without asking the user between rounds until all
four scores are at least 8/10, a genuine blocker is recorded, or the safe
working budget is reached.

Runtime values are caller-provided:

- Reasoning model: `{{REASONING_MODEL}}`; limit: `{{REASONING_LIMIT}}`
- Context model: `{{CONTEXT_MODEL}}`; limit: `{{CONTEXT_LIMIT}}`

Update `STATE.md`, verify each slice, and record visual evidence in
`docs/patch-notes/` when applicable.
