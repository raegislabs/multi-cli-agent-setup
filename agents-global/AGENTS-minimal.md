# User-Level Agentic Rules (Global SSoT)

This file is the single source of truth for user-level coding agent rules.

## Symlink Architecture

### User-Level (Global)
All AI coding assistants symlink to this single file for consistent global rules:
- **Claude Code**: `~/.claude/CLAUDE.md` → `~/.agents-global/AGENTS.md`
- **Codex**: `~/.codex/AGENTS.md` → `~/.agents-global/AGENTS.md`
- **OpenCode**: `~/.config/opencode/AGENTS.md` → `~/.agents-global/AGENTS.md`
- **Gemini CLI**: `~/.gemini/GEMINI.md` → `~/.agents-global/AGENTS.md`

### Project-Level
Each project has a `PROJECT-AGENTS.md` file with project-specific instructions:
- `.claude/CLAUDE.md` → `../PROJECT-AGENTS.md`
- `.codex/AGENTS.md` → `../PROJECT-AGENTS.md`
- `.opencode/AGENTS.md` → `../PROJECT-AGENTS.md`
- `GEMINI.md` → `PROJECT-AGENTS.md`

**Policies:**
- Security: Never commit secrets; use environment variables.
- Documentation: Do not auto-create docs unless explicitly requested.

---

## Cross-CLI Agent Invocation

Agents can spawn other AI tools via CLI for specialized tasks:
- **Gemini**: Large context analysis (>100K tokens), codebase-wide searches
- **Claude**: Complex reasoning, nuanced decisions, code generation
- **Codex**: Autonomous multi-step implementation, refactoring

```bash
# Claude non-interactive
claude -p "your prompt here"

# Gemini with file inclusion
gemini -p "Analyze: @src/ @tests/"

# Codex non-interactive
codex exec "your task description"

# Codex with sandbox
codex exec --sandbox workspace-write "refactor auth module"

# OpenCode with agent
opencode --agent architect
```

### Cross-Invocation Example
```bash
# Gemini analyzes → Claude reasons → Codex implements
gemini -p "Identify all technical debt in: @src/" > /tmp/tech-debt.md
claude -p "Prioritize this technical debt list: $(cat /tmp/tech-debt.md)"
codex exec --sandbox workspace-write "Fix top priority: ..."
```

---

## Task Completion Summaries

When completing any task, agents MUST provide:

- **What Was Done** — bullet points of changes with file paths
- **Impact** — what changed, benefits, breaking changes
- **Tests Completed** — commands run and results
- **Verification Needed** — checklist for the user
- **Follow-Up Needed** — explicit next actions or "Task complete"
- **TLDR** — one-paragraph executive summary

---

## Infrastructure Configuration

> Replace placeholders with your actual infrastructure details.

| Field | Value |
|-------|-------|
| **Provider** | `<YOUR_PROVIDER>` |
| **IP Address** | `<YOUR_SERVER_IP>` |
| **SSH Command** | `ssh -i ~/.ssh/<YOUR_KEY> <user>@<ip>` |

### Deployment Standards
- Never run services as root
- Bind to `127.0.0.1` only; use a reverse proxy for public traffic
- Use systemd with crash-loop protection (`StartLimitBurst=5`)
- Centralize env files; never commit them to git
