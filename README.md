# Agent Skills Repository

Personal and team skills for [opencode](https://github.com/anomalyco/opencode). Store your skills here and install them with `npx skills add <path>`.

## Usage

```bash
# Add a skill from this repo
npx skills add ./skills/backend-testing

# Or clone and use local path
git clone https://github.com/YOUR_USERNAME/agent-skills.git
npx skills add ./agent-skills/skills/backend-testing
```

## Available Skills

### Technical Skills

| Skill | Description | Category |
|-------|-------------|----------|
| [backend-testing](./skills/technical/backend-testing/README.md) | NestJS backend testing patterns | Testing |
| [git-best-practices](./skills/technical/git-best-practices/README.md) | Git workflow and conventions | VCS |
| [api-design](./skills/technical/api-design/README.md) | REST API design guidelines | Backend |

### Team Skills

| Skill | Description | Category |
|-------|-------------|----------|
| [team-code-style](./skills/team/team-code-style/README.md) | Team coding standards | Standards |
| [code-review](./skills/team/code-review/README.md) | Code review checklist | Process |

### Templates

| Template | Use Case |
|----------|----------|
| [basic](./skills/templates/basic/README.md) | Simple skill |
| [api-skill](./skills/templates/api-skill/README.md) | API integration |
| [testing-skill](./skills/templates/testing-skill/README.md) | Testing patterns |

## Creating a New Skill

1. Copy a template:
   ```bash
   cp -r skills/templates/basic skills/my-new-skill
   ```

2. Or use the script:
   ```bash
   ./scripts/create-skill.sh my-new-skill
   ```

3. Edit the skill file:
   ```markdown
   # skill: my-new-skill
   [Your skill content here]
   ```

## Skill Format

Each skill should follow the opencode skill format:

```markdown
# skill: skill-name

## Description
Brief description of what this skill does.

## When to Use
When to invoke this skill.

## Instructions
Detailed instructions for the agent.

## Examples
```example
Example usage
```
```

## Directory Structure

```
skills/
├── technical/      # Technical/programming skills
├── team/          # Team-specific workflows and standards
├── project/       # Project-specific skills
└── templates/     # Skill templates
```

## Contributing

1. Create skill in appropriate category
2. Add entry to this README
3. Test with `npx skills add ./skills/your-skill`
4. Commit and push

## License

MIT - See [LICENSE](LICENSE)
