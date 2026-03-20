# Agent Skills Repository

Personal and team skills. Store your skills here and install them with `npx skills add <path>`.

## 🚀 Quick Start

> **Prerequisite**: Install `skills` CLI before running `npx skills add`.
>
> ```bash
> npm install -g skills
> ```

## Usage

```bash
# Add a skill from this repo
npx skills add ./skills/nestjs-backend-testing

# Or clone and use local path
git clone https://github.com/YOUR_USERNAME/agent-skills.git
npx skills add ./agent-skills/skills/nestjs-backend-testing
```

## Available Skills

### Technical Skills

| Skill                                                               | Description                     | Category |
| ------------------------------------------------------------------- | ------------------------------- | -------- |
| [nestjs-backend-testing](./skills/nestjs-backend-testing/README.md) | NestJS backend testing patterns | Testing  |

### Templates

| Template                                    | Use Case     |
| ------------------------------------------- | ------------ |
| [basic](./skills/templates/basic/README.md) | Simple skill |

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

Each skill should follow the skill format:

````markdown
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
````

```

## Directory Structure

```

skills/ # Skills
└── templates/ # Skill templates

```

## Contributing

1. Create skill in appropriate category
2. Add entry to this README
3. Test with `npx skills add ./skills/your-skill`
4. Commit and push

## License

MIT - See [LICENSE](LICENSE)
```
