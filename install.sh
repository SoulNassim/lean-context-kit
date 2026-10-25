#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/.build"
CONFIG_FILE="${CONFIG_FILE:-$SCRIPT_DIR/config.env}"
WORKSPACE_DIR=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [--workspace PATH]

Installs the current Copilot workflow for the user. When --workspace is
provided, it also materializes .github/agents, .github/prompts, and
.github/skills/studio in that workspace for automatic VS Code discovery.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --workspace)
      [ "$#" -ge 2 ] || { printf '%s\n' '--workspace requires a path' >&2; exit 2; }
      WORKSPACE_DIR="$2"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done
if [ ! -f "$CONFIG_FILE" ]; then
  CONFIG_FILE="$SCRIPT_DIR/config.example.env"
fi

REASONING_MODEL=""
REASONING_LIMIT=""
CONTEXT_MODEL=""
CONTEXT_LIMIT=""

read_config() {
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      ""|\#*) continue ;;
      REASONING_MODEL=*) REASONING_MODEL="${line#*=}" ;;
      REASONING_LIMIT=*) REASONING_LIMIT="${line#*=}" ;;
      CONTEXT_MODEL=*) CONTEXT_MODEL="${line#*=}" ;;
      CONTEXT_LIMIT=*) CONTEXT_LIMIT="${line#*=}" ;;
      *) printf 'Ignoring unknown config key in %s\n' "$CONFIG_FILE" >&2 ;;
    esac
  done < "$CONFIG_FILE"
}

strip_quotes() {
  value="$1"
  case "$value" in
    \"*\") value="${value#\"}"; value="${value%\"}" ;;
    \'*\') value="${value#\'}"; value="${value%\'}" ;;
  esac
  printf '%s' "$value"
}

read_config
REASONING_MODEL="$(strip_quotes "$REASONING_MODEL")"
REASONING_LIMIT="$(strip_quotes "$REASONING_LIMIT")"
CONTEXT_MODEL="$(strip_quotes "$CONTEXT_MODEL")"
CONTEXT_LIMIT="$(strip_quotes "$CONTEXT_LIMIT")"

for key in REASONING_MODEL REASONING_LIMIT CONTEXT_MODEL CONTEXT_LIMIT; do
  value="${!key}"
  if [ -z "$value" ]; then
    printf 'Missing %s in %s\n' "$key" "$CONFIG_FILE" >&2
    exit 1
  fi
done

case "$(uname -s 2>/dev/null || printf unknown)" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT*) IS_WINDOWS=1 ;;
  *) IS_WINDOWS=0 ;;
esac

escape_sed() {
  printf '%s' "$1" | sed 's/[&|]/\\&/g'
}

replace_placeholders() {
  file="$1"
  reasoning_model="$(escape_sed "$REASONING_MODEL")"
  reasoning_limit="$(escape_sed "$REASONING_LIMIT")"
  context_model="$(escape_sed "$CONTEXT_MODEL")"
  context_limit="$(escape_sed "$CONTEXT_LIMIT")"
  sed \
    -e "s|{{REASONING_MODEL}}|$reasoning_model|g" \
    -e "s|{{REASONING_LIMIT}}|$reasoning_limit|g" \
    -e "s|{{CONTEXT_MODEL}}|$context_model|g" \
    -e "s|{{CONTEXT_LIMIT}}|$context_limit|g" \
    "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/core" "$BUILD_DIR/adapters/vscode/agents" \
  "$BUILD_DIR/adapters/vscode/prompts" "$BUILD_DIR/adapters/vscode/skills/studio" \
  "$BUILD_DIR/adapters/cursor" "$BUILD_DIR/adapters/hermes"
cp "$SCRIPT_DIR"/core/*.md "$BUILD_DIR/core/"
cp "$SCRIPT_DIR"/adapters/vscode/agents/*.agent.md "$BUILD_DIR/adapters/vscode/agents/"
cp "$SCRIPT_DIR"/adapters/vscode/prompts/*.prompt.md "$BUILD_DIR/adapters/vscode/prompts/"
cp "$SCRIPT_DIR"/adapters/vscode/skills/studio/SKILL.md \
  "$BUILD_DIR/adapters/vscode/skills/studio/SKILL.md"
cp "$SCRIPT_DIR"/adapters/cursor/*.md "$BUILD_DIR/adapters/cursor/"
cp -R "$SCRIPT_DIR"/adapters/hermes/. "$BUILD_DIR/adapters/hermes/"

while IFS= read -r -d '' file; do
  replace_placeholders "$file"
done < <(find "$BUILD_DIR" -type f -name '*.md' -print0)

if [ "$IS_WINDOWS" -eq 1 ]; then
  if [ -z "${APPDATA:-}" ]; then
    VSCODE_USER_PROMPTS_DIR="${VSCODE_USER_PROMPTS_DIR:-$HOME/.config/Code/User/prompts}"
  else
    VSCODE_USER_PROMPTS_DIR="${VSCODE_USER_PROMPTS_DIR:-$APPDATA/Code/User/prompts}"
  fi
else
  VSCODE_USER_PROMPTS_DIR="${VSCODE_USER_PROMPTS_DIR:-$HOME/.config/Code/User/prompts}"
fi
CURSOR_COMMANDS_DIR="${CURSOR_COMMANDS_DIR:-$HOME/.cursor/commands}"
HERMES_SKILLS_DIR="${HERMES_SKILLS_DIR:-$HOME/.hermes/skills}"

link_or_copy() {
  source_path="$1"
  target_path="$2"
  mkdir -p "$(dirname "$target_path")"
  rm -rf "$target_path"
  if [ "$IS_WINDOWS" -eq 1 ]; then
    cp -R "$source_path" "$target_path"
  else
    ln -sf "$source_path" "$target_path"
  fi
}

copy_file() {
  source_path="$1"
  target_path="$2"
  mkdir -p "$(dirname "$target_path")"
  rm -rf "$target_path"
  cp -R "$source_path" "$target_path"
}

COPILOT_AGENTS_DIR="${COPILOT_AGENTS_DIR:-$HOME/.copilot/agents}"
COPILOT_SKILLS_DIR="${COPILOT_SKILLS_DIR:-$HOME/.copilot/skills}"

for agent_file in "$BUILD_DIR"/adapters/vscode/agents/*.agent.md; do
  link_or_copy "$agent_file" \
    "$COPILOT_AGENTS_DIR/$(basename "$agent_file")"
done
link_or_copy "$BUILD_DIR/adapters/vscode/prompts/studio.prompt.md" \
  "$VSCODE_USER_PROMPTS_DIR/studio.prompt.md"
link_or_copy "$BUILD_DIR/adapters/vscode/prompts/direction.prompt.md" \
  "$VSCODE_USER_PROMPTS_DIR/direction.prompt.md"
link_or_copy "$BUILD_DIR/adapters/vscode/skills/studio/SKILL.md" \
  "$COPILOT_SKILLS_DIR/studio/SKILL.md"

link_or_copy "$BUILD_DIR/adapters/cursor/context-shield.md" \
  "$CURSOR_COMMANDS_DIR/context-shield.md"
link_or_copy "$BUILD_DIR/adapters/cursor/studio.md" \
  "$CURSOR_COMMANDS_DIR/studio.md"
link_or_copy "$BUILD_DIR/core/context-shield.md" \
  "$CURSOR_COMMANDS_DIR/_lean-context-kit/context-shield-core.md"
link_or_copy "$BUILD_DIR/core/studio-loop.md" \
  "$CURSOR_COMMANDS_DIR/_lean-context-kit/studio-loop-core.md"

for skill in context-shield studio; do
  mkdir -p "$HERMES_SKILLS_DIR/$skill/references"
  if [ "$skill" = "context-shield" ]; then
    core_name="context-shield"
  else
    core_name="studio-loop"
  fi
  link_or_copy "$BUILD_DIR/adapters/hermes/$skill/SKILL.md" \
    "$HERMES_SKILLS_DIR/$skill/SKILL.md"
  link_or_copy "$BUILD_DIR/core/$core_name.md" \
    "$HERMES_SKILLS_DIR/$skill/references/$core_name-core.md"
done

if [ -n "$WORKSPACE_DIR" ]; then
  WORKSPACE_DIR="$(CDPATH= cd -- "$WORKSPACE_DIR" && pwd)"
  for agent_file in "$BUILD_DIR"/adapters/vscode/agents/*.agent.md; do
    copy_file "$agent_file" \
      "$WORKSPACE_DIR/.github/agents/$(basename "$agent_file")"
  done
  copy_file "$BUILD_DIR/adapters/vscode/prompts/studio.prompt.md" \
    "$WORKSPACE_DIR/.github/prompts/studio.prompt.md"
  copy_file "$BUILD_DIR/adapters/vscode/prompts/direction.prompt.md" \
    "$WORKSPACE_DIR/.github/prompts/direction.prompt.md"
  copy_file "$BUILD_DIR/adapters/vscode/skills/studio/SKILL.md" \
    "$WORKSPACE_DIR/.github/skills/studio/SKILL.md"
  printf 'Installed workspace Copilot files in %s/.github\n' "$WORKSPACE_DIR"
fi

printf 'Built substituted templates in %s\n' "$BUILD_DIR"
printf 'Installed Copilot agents in %s\n' "$COPILOT_AGENTS_DIR"
printf 'Installed VS Code prompts in %s\n' "$VSCODE_USER_PROMPTS_DIR"
printf 'Installed Copilot skills in %s\n' "$COPILOT_SKILLS_DIR"
printf 'Installed Cursor commands in %s\n' "$CURSOR_COMMANDS_DIR"
printf 'Installed Hermes skills in %s\n' "$HERMES_SKILLS_DIR"
