---
name: direction
description: "Steer the style in one sentence, e.g. /direction mehr retro, weniger neon"
agent: orchestrator
---
The user gave a new style direction (the text after `/direction`).
1. Add it to `DESIGN.md` as a `[USER]` line, unchanged. Replace an older `[USER]` line only if they directly conflict, and log it in `## Änderungslog`. Adjust `[AUTO]` details minimally so they match.
2. Show the user the 3 most important visible changes in 3 lines.
3. Add up to 3 `- [ ]` tasks to the top of `STATE.md` that bring the build in line, each ending with `(DESIGN.md)`.
4. Ensure `.agent-out/` is in `.gitignore`, then commit (`git add DESIGN.md STATE.md .gitignore && git commit -m "design: steer" 2>&1 | tail -n 10`). Then say: "Starte `/studio continue`, um es umzusetzen."
Do not start the build loop here.