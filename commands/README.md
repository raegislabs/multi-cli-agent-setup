# Commands

Commands are reusable prompts that can be invoked by name in each CLI. Unlike skills (which are triggered contextually), commands are explicitly called by the user.

Each CLI has its own command format. This directory shows the **same command** written for all three CLIs so you can see the differences.

## Format Comparison

| Feature | Claude Code | Codex | Gemini CLI |
|---------|-------------|-------|------------|
| **File format** | Markdown (`.md`) | Markdown (`.md`) | TOML (`.toml`) |
| **Metadata** | YAML frontmatter | Filename convention | TOML keys |
| **Location (user)** | `~/.claude/commands/` | `~/.codex/commands/` | `~/.gemini/commands/` |
| **Location (project)** | `.claude/commands/` | `.codex/commands/` | `GEMINI.md` inline |
| **Invocation** | `/command-name` | `/command-name` | `/command-name` |
| **Arguments** | `$ARGUMENTS` placeholder | `$ARGUMENTS` placeholder | `{{args}}` placeholder |

## Installation

Copy the command file for your CLI into the appropriate directory:

```bash
# Claude Code (user-level)
cp commands/claude/example-healthcheck.md ~/.claude/commands/

# Codex (user-level)
cp commands/codex/example_healthcheck.md ~/.codex/commands/

# Gemini CLI (user-level)
cp commands/gemini/example-healthcheck.toml ~/.gemini/commands/
```

## Example: Healthcheck Command

The `healthcheck` command checks if a service is running by hitting its health endpoint and reporting status. See each CLI's implementation in this directory.

## Creating Your Own Commands

1. Pick a descriptive name (kebab-case for Claude/Gemini, snake_case for Codex)
2. Write the prompt in the CLI's format
3. Use argument placeholders (`$ARGUMENTS` or `{{args}}`) for dynamic input
4. Install to the user or project command directory
5. Test with: `/<command-name> <args>`
