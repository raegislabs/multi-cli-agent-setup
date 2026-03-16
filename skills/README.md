# Skills

Skills are reusable prompts that teach AI coding agents specialized behaviors. They work the same way across Claude Code, Codex, and Gemini CLI.

## How Skills Work

A skill is a `SKILL.md` file containing:
1. **YAML frontmatter** — metadata (name, description, when to trigger)
2. **Markdown body** — the actual instructions the agent follows

```markdown
---
name: my-skill
description: What this skill does
---

# My Skill

Instructions for the agent go here...
```

## Installation

### Claude Code
```bash
# User-level (available in all projects)
cp -r skills/code-review-checklist ~/.claude/skills/

# Project-level (available only in this project)
cp -r skills/code-review-checklist .claude/skills/
```

### Codex
```bash
# User-level
cp skills/code-review-checklist/SKILL.md ~/.codex/skills/code-review-checklist.md

# Project-level
cp skills/code-review-checklist/SKILL.md .codex/skills/code-review-checklist.md
```

### Gemini CLI
```bash
# User-level
cp skills/code-review-checklist/SKILL.md ~/.gemini/skills/code-review-checklist.md
```

## Skill Structure

### Simple skill (single file)
```
skills/
  code-review-checklist/
    SKILL.md
```

### Skill with references (bundled docs)
```
skills/
  deployment-helper/
    SKILL.md
    references/
      deploy-checklist.md
      rollback-procedure.md
```

The `references/` directory contains supporting documents that the skill can reference. The agent reads these as additional context when the skill is invoked.

## Creating Your Own Skills

1. Create a new directory under `skills/`
2. Add a `SKILL.md` with frontmatter and instructions
3. Optionally add a `references/` directory for supporting docs
4. Install to your CLI of choice using the paths above

### Tips
- Keep skills focused on one task
- Use concrete examples and code blocks in instructions
- Reference exact file patterns the agent should look for
- Include "when to use" and "when NOT to use" guidance
- Test with multiple CLIs to ensure portability
