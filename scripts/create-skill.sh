#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$(dirname "$SCRIPT_DIR")/skills"

if [ -z "$1" ]; then
  echo "Usage: ./scripts/create-skill.sh <skill-name>"
  echo ""
  echo "Creates a new skill from the basic template."
  exit 1
fi

SKILL_NAME="$1"
SKILL_PATH="${SKILLS_DIR}/${SKILL_NAME}"

if [ -d "$SKILL_PATH" ]; then
  echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_PATH"
  exit 1
fi

cp -r "${SKILLS_DIR}/templates/basic" "$SKILL_PATH"

echo "✓ Created skill at: $SKILL_PATH"
echo ""
echo "Next steps:"
echo "  1. Edit: $SKILL_PATH/README.md"
echo "  2. Add to README.md main file"
echo "  3. Test with: npx skills add ./$SKILL_PATH"
