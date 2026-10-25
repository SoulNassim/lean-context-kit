# Studio Loop

Studio is an autonomous Builder <-> Adversarial Critic loop for small games and
interactive prototypes. It is deliberately model-agnostic:

- Reasoning lane: `{{REASONING_MODEL}}` / `{{REASONING_LIMIT}}`
- Context lane: `{{CONTEXT_MODEL}}` / `{{CONTEXT_LIMIT}}`

The loop owns implementation, evidence collection, and corrective work. It does
not ask the user whether to continue between rounds. It pauses only at a safe
context boundary, a genuine blocker, or the release gate.

## Phase 0: five-tier roadmap

Turn the request into one vertical roadmap before making polish-only changes:

1. **Core loop and telemetry** — make the primary interaction playable and
   expose the required runtime hooks.
2. **Depth and variety** — add meaningful choices, enemies, upgrades, or
   progression that change decisions rather than only increasing counts.
3. **Visual juice and readability** — improve hierarchy, motion, particles,
   state changes, contrast, and responsive layout.
4. **Audio, feedback, and meta-loop** — add purposeful sound or haptic-equivalent
   feedback, rewards, restart flow, and longer-term motivation where applicable.
5. **UI, accessibility, and polish** — finish menus, pause/end states, input
   affordances, keyboard/focus behavior, mobile layout, and error recovery.

At the end of Phase 0, write the roadmap and acceptance checks to `STATE.md`.
Every playable build must expose a small, serializable inspection contract:

```js
window.__GAME_STATE__ = {
  fps,
  scene,
  score,
  playerHp,
  enemies,
  particles,
  upgrades
};

window.__AUTOPLAY__ = (enabled) => {
  // Enable or disable deterministic smoke-test input.
};
```

The keys must be present even when their values are zero or their collections
are empty. Keep the contract stable while iterating so `scripts/playtest.mjs`
can verify it without knowing the game's internals.

## Phase 1: Builder foundation

The Builder selects the next ready tier task, reads only the files needed for
that task, and implements the smallest coherent slice. It preserves working
behavior, updates `STATE.md`, and runs the task's verification command. A task
is not complete because the app starts; it is complete when the requested
behavior and its observable evidence exist.

The Builder should prefer deterministic hooks, semantic selectors, and
reproducible screenshots. If a feature cannot be verified yet, queue the
instrumentation or test as a dependency instead of claiming completion.

## Phase 2: endless Builder <-> Adversarial Critic

After each Builder slice, run a separate read-only Critic pass. The Critic
reproduces the acceptance checks, probes edge cases, reviews the visual result,
and scores exactly these four rubrics from 1 to 10:

| Rubric | Question |
| --- | --- |
| **Depth / Mechanics** | Does the interaction create meaningful decisions and a satisfying loop? |
| **Visual Juice / Polish** | Are hierarchy, motion, readability, responsiveness, and state changes convincing? |
| **Audio / Feedback** | Do actions, danger, success, and failure communicate clearly through available feedback? |
| **Zero-Bug Stability** | Do normal, boundary, restart, resize, keyboard, and autoplay paths remain reliable? |

The release gate is **at least 8/10 on every rubric**. A total average is not
enough: one score below 8 always queues corrective work. The Critic writes
ranked findings with reproduction steps and evidence, then turns each accepted
finding into an atomic Builder task. The Builder fixes the highest-impact
finding first, reruns verification, and hands the result to the Critic again.

Continue the loop automatically, without a user question between rounds, until
all four scores are at least 8/10, no ready corrective task remains, a genuine
blocker is recorded, or the safe working budget is reached. Never lower a score
to force release. When a boundary is reached, update `STATE.md` with scores,
evidence, unfinished tasks, and the exact next action before handing off.

## Phase 3: release verification

When the gate passes, run the smallest full-path check available: unit tests,
the headless playtest, and a matching visual capture when the project has a
visual surface. Confirm the required runtime hooks, inspect console and page
errors, and record the final four scores and commands in `STATE.md` and the
appropriate `docs/patch-notes/` note.

If the gate cannot pass, report the blocker plainly. Do not silently skip a
rubric, substitute a subjective claim for a check, or leave the project in a
success-shaped state with failing diagnostics.
