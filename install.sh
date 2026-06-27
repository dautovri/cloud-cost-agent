#!/bin/bash
#
# Cloud Cost Agent - installer
# Works two ways:
#   1. From a clone:   ./install.sh
#   2. Piped remotely: curl -sL https://raw.githubusercontent.com/dautovri/cloud-cost-agent/main/install.sh | bash
#
# Override the target agent with: --tool claude|cursor|gemini|grok|generic
#

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/dautovri/cloud-cost-agent/main/skills/cloud-cost-agent"
TOOL="auto"

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool) TOOL="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "☁️  Installing Cloud Cost Agent skill..."

# Detect agent if not specified
if [[ "$TOOL" == "auto" ]]; then
  if   [[ -n "${GROK_SKILLS_DIR:-}" || -d "$HOME/.grok/skills" ]]; then TOOL="grok"
  elif [[ -d "$HOME/.claude/skills"  || -d "$HOME/.claude" ]];      then TOOL="claude"
  elif [[ -d "$HOME/.cursor" ]];                                    then TOOL="cursor"
  elif command -v gemini &>/dev/null;                               then TOOL="gemini"
  else TOOL="generic"; fi
fi

case $TOOL in
  grok)          SKILL_DIR="$HOME/.grok/skills/cloud-cost-agent" ;;
  claude)        SKILL_DIR="$HOME/.claude/skills/cloud-cost-agent" ;;
  cursor)        SKILL_DIR="$HOME/.cursor/skills/cloud-cost-agent" ;;
  gemini|gemini-cli) SKILL_DIR="$HOME/.gemini/skills/cloud-cost-agent" ;;
  generic|*)     SKILL_DIR="$HOME/.agent-skills/cloud-cost-agent" ;;
esac

mkdir -p "$SKILL_DIR/docs"

# Use local files if present (clone), otherwise download them (curl | bash)
SRC="skills/cloud-cost-agent"
if [[ -f "$SRC/SKILL.md" ]]; then
  cp "$SRC/SKILL.md" "$SKILL_DIR/"
  cp -r "$SRC/docs/." "$SKILL_DIR/docs/" 2>/dev/null || true
else
  curl -fsSL "$RAW_BASE/SKILL.md" -o "$SKILL_DIR/SKILL.md"
  for f in iam-readonly-policy.json aws-setup.md gcp-setup.md azure-setup.md; do
    curl -fsSL "$RAW_BASE/docs/$f" -o "$SKILL_DIR/docs/$f" 2>/dev/null || true
  done
fi

echo "✅ Installed ($TOOL) → $SKILL_DIR"
echo ""
echo "Next:"
echo "  1. Authenticate your clouds:  aws sso login  /  gcloud auth login  /  az login"
echo "  2. In your agent:             /cloud-cost-agent audit my spend"
