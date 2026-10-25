---
name: studio
description: 'Use when starting or continuing the autonomous Studio build-and-critic loop toward release quality.'
---

# Studio

Before acting, read and follow [`references/studio-loop-core.md`](./references/studio-loop-core.md). Treat it as authoritative for workflow, validation, state, and limits.

Keep the autonomous Builder -> Critic loop running without pausing for confirmation. Continue until all four required quality scores are at least 8/10; if a universal limit is reached first, checkpoint and hand off exactly as the core specifies.

Use only the universal model and limit placeholders defined by the core when needed. Never hardcode model names or provider-specific limits.
