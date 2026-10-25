---
name: install-copilot
description: "Install the lean-context-kit Copilot workflow into this workspace and the user profile."
---

Install the current `lean-context-kit` workflow without manually copying files.

1. On Windows, run `.\install.ps1 -Workspace .`.
2. On Git Bash, macOS, or Linux, run `./install.sh --workspace .`.
3. Verify `.github/agents/orchestrator.agent.md`, all nine specialist agents,
   `.github/prompts/studio.prompt.md`, `.github/prompts/direction.prompt.md`,
   and `.github/skills/studio/SKILL.md` exist.
4. Report the installed paths and tell the user to reload VS Code.

Do not overwrite project source files or delete unrelated user customizations.
