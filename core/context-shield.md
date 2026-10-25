# Context Shield

Context Shield is a model-agnostic operating guide for reliable agent work when the
available context window is smaller than the project. It keeps the active thread
small, makes durable state explicit, and treats verification as part of the task.

Runtime values are supplied by the caller or by `install.sh`:

- Reasoning lane: `{{REASONING_MODEL}}` with `{{REASONING_LIMIT}}`
- Context lane: `{{CONTEXT_MODEL}}` with `{{CONTEXT_LIMIT}}`

## 1. Strict context hygiene

1. Start with one sentence for the goal, a list of authorized paths, constraints,
   and the measurable verification command.
2. Search for symbols and exact strings before reading files. Read only the
   smallest relevant range and summarize evidence immediately.
3. Keep unrelated defects out of the task. Do not expand scope because a nearby
   file is interesting, dirty, or easier to change.
4. Keep secrets, credentials, generated output, and private configuration out of
   prompts, logs, screenshots, commits, and handoff notes.
5. Prefer durable facts over narrative: record decisions, open risks, and the
   next executable action in `STATE.md`.

## 2. The 60% safe working budget

Treat 60% of the active context limit as the maximum working budget. Reserve the
remaining 40% for tool results, test output, corrections, and a clean handoff.
Apply this rule independently to the reasoning lane (`{{REASONING_LIMIT}}`) and
the context lane (`{{CONTEXT_LIMIT}}`); never assume that a nominal total is all
available for input.

At each checkpoint, estimate what remains. If the safe budget is nearly spent,
stop opening new files, summarize verified facts, update `STATE.md`, and leave a
precise next action. A shorter verified handoff is better than a long,
context-truncated answer.

## 3. Bounded reads, terminals, and edits

- Cap every individual file read at 120 lines. Run a line count or a focused
  search first; read another bounded range only when evidence requires it.
- Cap terminal output with `2>&1 | tail -n 30`. For longer builds or tests,
  write a log and inspect only targeted excerpts.
- Make no more than three main-thread edit batches for one atomic task. Group
  related changes, then validate before editing again.
- Use existing helpers, types, and project conventions. Do not replace a
  precise fix with a broad formatter or an unrelated cleanup.
- Treat exit codes, compiler diagnostics, and test assertions as evidence; never
  report success from a command that was not actually run.

## 4. Delegation without context copies

Delegate only a bounded, independently verifiable objective. Give a worker a
zero-copy brief: goal, exact allowed files, read/write mode, stop condition,
verification command, and output path. The worker must first read
`.agent/WORKER_RULES.md`; that file is the compact contract for tools, reads,
edits, and handoffs.

Workers do not spawn workers, edit `STATE.md`, or rewrite files outside their
allowlist. They return a short result in `.agent-out/` and include the paths and
line ranges that support each claim. The main thread integrates the result,
resolves conflicts, and runs the final verification; a worker report is not a
substitute for an integration check.

## 5. Visual patch notes

For UI or game work, keep visual evidence under `docs/patch-notes/`:

1. Capture a named before image before the first visual edit when possible.
2. Capture a matching after image at the same viewport and state.
3. Record the changed surfaces, responsive states, interaction checks, and
   unresolved visual risks in a concise HTML or Markdown note.
4. Keep automated screenshots such as `latest-screen.png` reproducible and do
   not commit them when the repository policy says they are local artifacts.

If no visual surface exists, say so explicitly in the patch note instead of
inventing a screenshot comparison.

## 6. STATE.md loop engineering and the verification gate

`STATE.md` is the durable loop ledger. Keep these fields current:

- Goal and constraints, including the exact workspace boundary.
- Baseline and known failures before editing.
- Counters for tool calls, context, and main-thread edit batches.
- An atomic task queue with dependencies, status, and a concrete verification
  command for each item.
- Decisions, patch-note status, and one next immediate action.

Before marking a task done, pass its verification gate: inspect the relevant
diff, run the smallest applicable test or check, confirm the expected output
shape, and record the result. On failure, preserve the error, fix only the
root cause in scope, and rerun the gate. On a context or tool limit, checkpoint
the exact state and leave the first safe next action.

## 7. Finish, hand off, and resume safely

The final report names changed files, verification commands and outcomes,
remaining risks, and the next action. It distinguishes verified facts from
assumptions and never hides an error behind a success-shaped fallback.

Before handing off, check that generated files are ignored where intended,
placeholders remain in source templates, platform-specific paths have a
portable fallback, and no credentials or private configuration are staged.
When resuming, read `STATE.md` first, re-establish the scope, and continue at
the first ready atomic task rather than rereading the whole project.
