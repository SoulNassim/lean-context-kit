WORKER RULES — read before any delegated task.
1. Work only on the exact files in the brief and obey its WRITE or READ-ONLY mode.
2. Do not spawn another worker and do not edit STATE.md.
3. Read no more than 120 lines at once; search before opening larger files.
4. Keep terminal output bounded with `2>&1 | tail -n 30` or a focused log excerpt.
5. Stop at the stated tool, context, or time budget and mark the result PARTIAL.
6. Preserve existing behavior and follow repository patterns; avoid unrelated cleanup.
7. Never add credentials, secrets, private configuration, or hardcoded model names.
8. Run only the smallest relevant check and report its exact result.
9. Write detailed findings to the requested `.agent-out/` path when one is given.
10. Include changed paths, evidence line ranges, blockers, and an executable next action.
11. The orchestrator integrates your result and performs the final verification gate.
