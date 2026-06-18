#!/bin/bash
#
# Cloud Cost Agent - One-liner installer
# Supports: grok, claude, cursor, gemini-cli, and generic agent skills
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/dautovri/cloud-cost-agent/main/install.sh | bash
#   curl -sL ... | bash -s -- --tool gemini
#

set -e

TOOL="auto"
SKILL_DIR=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --tool)
      TOOL="$2"
      shift 2
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo "☁️  Installing Cloud Cost Agent skills..."

# Detect tool if auto
if [[ "$TOOL" == "auto" ]]; then
  if [[ -n "$GROK_SKILLS_DIR" || -d "$HOME/.grok/skills" ]]; then
    TOOL="grok"
  elif [[ -d "$HOME/.claude/skills" ]]; then
    TOOL="claude"
  elif command -v gemini &> /dev/null; then
    TOOL="gemini"
  else
    TOOL="generic"
  fi
fi

case $TOOL in
  grok)
    SKILL_DIR="$HOME/.grok/skills/cloud-cost-agent"
    ;;
  claude)
    SKILL_DIR="$HOME/.claude/skills/cloud-cost-agent"
    ;;
  gemini|gemini-cli)
    SKILL_DIR="$HOME/.gemini/skills/cloud-cost-agent"  # or wherever Gemini CLI looks; adjust as needed
    echo "Note: For Gemini CLI, you may need to run: gemini skills install ."
    ;;
  generic|*)
    SKILL_DIR="$HOME/.agent-skills/cloud-cost-agent"
    echo "Installing to generic location. Copy manually to your agent's skills dir."
    ;;
esac

mkdir -p "$SKILL_DIR"
cp SKILL.md "$SKILL_DIR/"
cp -r docs "$SKILL_DIR/" 2>/dev/null || true

echo "✅ Installed to $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Authenticate to your clouds (aws/gcloud/az login)"
echo "  2. In your agent: /cloud-cost-agent audit my spend"
echo ""
echo "For MCP / advanced use, see docs/ and PRODUCT.md"
echo "GitHub: https://github.com/dautovri/cloud-cost-agent"

# Optional: support npx-style or skills add in future
