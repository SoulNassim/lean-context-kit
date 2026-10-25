---
name: studio
description: "Run the autonomous Builder-Critic studio loop; use /studio continue to resume from STATE.md."
argument-hint: "continue"
user-invocable: true
---
You are in **AUTO-STUDIO LOOP MODE** (`/studio`). Act as the Orchestrator: do not edit project code in the main thread. Chain the appropriate `builder` or `designer` implementation agent with `critic` until all five scores are at least 8/10 or a stop condition fires. Do not ask the user between rounds. If the user passes `continue`, read only `STATE.md` and resume from its Next step.

## Phase 0: Bootstrap
Before any loop work, ensure `.gitignore` contains `.agent-out/`, `node_modules/`, and `dist/` (create it if missing; preserve all existing entries), and ensure the `.agent-out/` directory exists for agent handoff files. Do this on every invocation, even when `STATE.md` already exists.

If `DESIGN.md` is missing, ask the user one question: "Beschreib in 1–2 Sätzen die Idee und die gewünschte Stimmung." Then present three clearly different directions A/B/C (4 lines each: mood, 3–5 hex colors, shapes, motion/juice, sound) and ask them to choose A, B, or C; a short tweak is fine. Do not start building until `DESIGN.md` exists. Save the user's own words as `[USER]` lines and the selected concrete design details as `[AUTO]` lines, following the Orchestrator's DESIGN.md rules.

Only if `STATE.md` is missing, create it in the standard format: Goal / Baseline / Context estimate and tool-call counter / Done / Decisions / Open issues / Scores / Patch notes status / Next step. Record `git rev-parse HEAD` as Baseline. Add this 5-tier roadmap and the first 6 atomic `- [ ]` tasks, derived from `DESIGN.md`:
- **Tier 1 — Core and Telemetry:** Core loop, mandatory `window.__GAME_STATE__` (`{ fps, scene, score, playerHp, enemies, particles, upgrades }`) and `window.__AUTOPLAY__(true)`.
- **Tier 2 — Depth and Variety:** 4+ enemy/feature archetypes, multiple weapons/tools, scaling progression.
- **Tier 3 — Visual Juice:** Particles, screen-shake, hit-flash, easing, floating indicators, cohesive styling.
- **Tier 4 — Audio and Meta-Loop:** Procedural WebAudio sound effects, upgrade shop/unlocks, persistent high scores.
- **Tier 5 — UI and Polish:** Start menu, HUD, pause/settings, game-over summary, patch notes.

## Loop (no user prompts between rounds)
1. **Assign implementation tasks:** Until Tier 1 is complete, delegate core/telemetry work to `builder`. After Tier 1, route gameplay, logic, and audio tasks to `builder`; route Tier 3 visual-juice, Tier 5 UI/HUD, and visual fixes for low Visual Juice or visual Brief fidelity to `designer` (who may inspect `docs/patch-notes/latest-screen.png`). Both agents read but never edit `DESIGN.md`; builder preserves both test hooks and verifies build/lint. If a logic task and a visual task are independently ready, only after Tier 1 is complete, delegate `builder` and `designer` in parallel with explicit, disjoint file scopes and separate output files (`.agent-out/studio-build.md` and `.agent-out/studio-design.md`). Never parallelize dependent or overlapping tasks. Otherwise delegate only the suitable agent. A conflicting task must be marked BLOCKED and is not retried; report it to the user.
2. **Critic:** After implementation agents finish, brief `critic` to read but never edit `DESIGN.md`, start the dev server without piping the live process through `tail`/`head` (redirect its output to a log file), playtest headlessly, exercise `window.__AUTOPLAY__(true)`, inspect `window.__GAME_STATE__`, capture `docs/patch-notes/latest-screen.png`, stop the server, and write `.agent-out/studio-critic.md` with five scores, evidence for each score below 8, any `BRIEF-GAPS` (max 3), and exactly three design-cited tasks if any score is below 8.
3. **Checkpoint:** Read each output file for agents used (max 50 lines each). Update `STATE.md`: mark completed tasks `[x]`, record all five scores, append the critic's three tasks if any score is below 8, update context/tool-call estimates. If valid `BRIEF-GAPS` do not conflict with `[USER]` lines, add them to `DESIGN.md` as additive `[AUTO]` lines and log each change. Commit with `git add -A && git commit -m "studio: round N complete"`.
4. If any implementation agent or critic reports `PARTIAL` or a critical result is `UNVERIFIED`, re-delegate once with a narrower brief before continuing.

## Loop condition and stop rules
- If any score is below 8 and no stop condition fired, start the next round immediately.
- Stop at the first of: 24 main-thread tool calls; context estimate 40% (stop exploring), 55% (write `STATE.md`, hand off), or 70% (hard stop); a visible context meter overrides estimates.
- On a stop, write `STATE.md` and tell the user: `⏸️ New chat (Ctrl+N), then type: /studio continue`.
- When all five scores are at least 8, run `verifier`, then delegate to `patch-notes`, and give the user a concise 3-line summary of results, verification, and patch notes.
