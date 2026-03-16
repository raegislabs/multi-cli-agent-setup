# multi-cli-agent-setup

Portable configuration, rules, skills, and commands for AI coding agents — works across **Claude Code**, **Codex**, **Gemini CLI**, and **OpenCode**.

## Why This Exists

Every AI coding CLI reads a markdown file for instructions (CLAUDE.md, AGENTS.md, GEMINI.md). If you use more than one CLI, you're maintaining the same rules in multiple places. This repo solves that with a single source of truth:

```
~/.agents-global/AGENTS.md          ← one file, all rules
    ↑           ↑           ↑           ↑
~/.claude/    ~/.codex/   ~/.gemini/  ~/.config/opencode/
CLAUDE.md     AGENTS.md   GEMINI.md   AGENTS.md
(symlink)     (symlink)   (symlink)   (symlink)
```

Every CLI reads the same file. Edit once, all agents update.

## What's Included

| Directory | Purpose |
|-----------|---------|
| `agents-global/` | Global agent rules (full + minimal templates) |
| `templates/` | Sanitized config examples for each CLI |
| `skills/` | Portable skills that work across all CLIs |
| `commands/` | Same command in each CLI's format |
| `project-level/` | Per-project setup script and template |

## Quick Start

```bash
git clone https://github.com/raegislabs/multi-cli-agent-setup.git
cd multi-cli-agent-setup

# Preview what will happen
./install.sh --dry-run --all

# Install everything (auto-detects which CLIs you have)
./install.sh --all

# Or install selectively
./install.sh --agents            # Just the global AGENTS.md
./install.sh --agents-minimal    # Starter version (~100 lines)
./install.sh --templates         # CLI config examples
./install.sh --skills            # Portable skills
./install.sh --commands          # Example commands
```

## Architecture

```
multi-cli-agent-setup/
├── agents-global/
│   ├── AGENTS.md              # Full template (~350 lines)
│   └── AGENTS-minimal.md      # Starter template (~100 lines)
│
├── templates/                  # CLI config examples (sanitized)
│   ├── claude/
│   │   ├── mcp.json.example   # MCP server patterns
│   │   └── claude.json.example
│   ├── codex/
│   │   └── config.toml.example
│   ├── gemini/
│   │   └── settings.json.example
│   └── opencode/
│       └── opencode.json.example
│
├── skills/                     # Portable across all CLIs
│   ├── code-review-checklist/
│   │   └── SKILL.md
│   └── deployment-helper/
│       ├── SKILL.md
│       └── references/
│           └── deploy-checklist.md
│
├── commands/                   # Same command, 3 formats
│   ├── claude/
│   │   └── example-healthcheck.md
│   ├── codex/
│   │   └── example_healthcheck.md
│   └── gemini/
│       └── example-healthcheck.toml
│
├── project-level/              # Per-project setup
│   ├── PROJECT-AGENTS.md.example
│   └── setup-project.sh
│
└── install.sh                  # Modular installer
```

## Customization

### 1. Edit your global rules

After installing, edit `~/.agents-global/AGENTS.md`:
- Replace `<YOUR_PROVIDER>`, `<YOUR_SERVER_IP>`, etc. with your infrastructure details
- Add deployment standards specific to your stack
- Add cross-CLI invocation patterns you use

### 2. Configure each CLI

Copy and rename the `.example` files:
```bash
# Claude Code MCP servers
cp ~/.claude/mcp.json.example ~/.claude/.mcp.json
# Edit with your API keys

# Codex
cp ~/.codex/config.toml.example ~/.codex/config.toml
# Edit with your project paths
```

### 3. Set up a project

```bash
# Copy the template
cp project-level/PROJECT-AGENTS.md.example /path/to/your/project/PROJECT-AGENTS.md

# Create symlinks for all CLIs
./project-level/setup-project.sh /path/to/your/project
```

This creates:
```
your-project/
├── PROJECT-AGENTS.md           # Your project rules (edit this)
├── .claude/CLAUDE.md           → ../PROJECT-AGENTS.md
├── .codex/AGENTS.md            → ../PROJECT-AGENTS.md
├── .opencode/AGENTS.md         → ../PROJECT-AGENTS.md
└── GEMINI.md                   → PROJECT-AGENTS.md
```

### 4. Add your own skills

Create a directory under `skills/` with a `SKILL.md`:
```bash
mkdir -p skills/my-custom-skill
# Write your SKILL.md with YAML frontmatter + instructions
# Reinstall: ./install.sh --skills
```

## Uninstall

```bash
./install.sh --uninstall
```

Removes all symlinks and installed files. Restores backups where available.

## Companion Repo

This repo handles the **agent configuration layer** (rules, skills, commands, MCP patterns).

For the **terminal layer** (WezTerm + Zellij, persistent sessions, AI-optimized layouts), see:
[**raegislabs/terminal-ai-workspace**](https://github.com/raegislabs/terminal-ai-workspace)

Together they give you a complete AI-assisted development environment:
```
terminal-ai-workspace      → Terminal multiplexer + window management
multi-cli-agent-setup      → Agent rules + skills + commands
```

## License

MIT
