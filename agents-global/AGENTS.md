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
Each project has a `PROJECT-AGENTS.md` file with project-specific instructions, symlinked by:
- `.claude/CLAUDE.md` → `../PROJECT-AGENTS.md`
- `.codex/AGENTS.md` → `../PROJECT-AGENTS.md`
- `.opencode/AGENTS.md` → `../PROJECT-AGENTS.md`
- `GEMINI.md` → `PROJECT-AGENTS.md`

Project-level files extend or override these global rules for specific repositories.

**Policies:**
- Security: Never commit secrets; use environment variables.
- Documentation: Do not auto-create docs unless explicitly requested.

---

## Cross-CLI Agent Invocation

Agents can spawn other AI tools via CLI for specialized tasks. This enables:
- Using Gemini's large context window for codebase-wide analysis
- Using Codex's agentic capabilities for autonomous refactoring
- Using Claude for complex reasoning and code generation

### Claude Code CLI

**Basic Usage:**
```bash
# Interactive mode
claude

# Non-interactive execution (exec mode)
claude -p "your prompt here"

# Uses default model (recommended)
# If specific model needed: claude --model <model> -p "your prompt"

# Continue last conversation
claude --continue

# Resume specific conversation
claude --resume <conversation-id>
```

**Key Flags:**
- `-p, --prompt`: Non-interactive single prompt execution
- `--model`: Choose model (use with caution - may cause errors if unavailable)
- `--continue`: Continue most recent conversation
- `--resume`: Resume specific conversation by ID
- `--allowedTools`: Restrict available tools
- `--disallowedTools`: Block specific tools
- `--max-turns`: Limit agentic turns

**Spawning from other agents:**
```bash
# From Gemini or Codex, run Claude for complex reasoning
claude -p "Analyze this architecture decision: ..."

# Run Claude with file context
claude -p "Review this code: $(cat src/main.py)"
```

### Gemini CLI

**Basic Usage:**
```bash
# Interactive mode
gemini

# Non-interactive execution
gemini -p "your prompt here"

# With file inclusion (uses @ syntax for large context)
gemini -p "Analyze: @src/ @tests/"

# Sandbox mode for code execution
gemini --sandbox -p "Write and test a sorting algorithm"
```

**Key Flags:**
- `-p, --prompt`: Non-interactive prompt execution
- `@path`: Include file/directory contents in context
- `--sandbox`: Enable code execution sandbox
- `--model`: Select model variant (use with caution - may cause errors if unavailable)

**Large Context Analysis (Gemini's strength):**
```bash
# Analyze entire codebase (leverages 1M+ token context)
gemini -p "Analyze the architecture of this codebase, identify patterns and potential issues: @src/ @lib/ @tests/"

# Cross-file dependency analysis
gemini -p "Map all imports and dependencies across: @**/*.py"

# Security audit across project
gemini -p "Perform security audit looking for vulnerabilities: @src/"
```

**Spawning from other agents:**
```bash
# From Claude or Codex, use Gemini for large-scale analysis
gemini -p "Analyze entire codebase for technical debt: @./"

# Pattern detection across many files
gemini -p "Find all usages of deprecated API across: @src/ @lib/"
```

### Codex CLI (OpenAI)

**Basic Usage:**
```bash
# Interactive mode
codex

# Non-interactive execution
codex exec "your task description"

# Uses default model automatically (recommended to avoid model selection errors)
# If specific model needed: codex exec -m <model-name> "task"

# With reasoning effort control
codex exec --config model_reasoning_effort="high" "complex task"

# Resume last session
codex exec resume --last
```

**Key Flags:**
- `exec`: Execute task non-interactively
- `-m, --model`: Model selection (use with caution - may cause errors if model unavailable)
- `--config model_reasoning_effort`: low/medium/high reasoning
- `--sandbox`: Sandbox mode (read-only, workspace-write, danger-full-access)
- `--full-auto`: Skip confirmations (use with caution)
- `resume --last`: Resume previous session

**Sandbox Modes:**
```bash
# Read-only (safest)
codex exec --sandbox read-only "analyze this code"

# Workspace write (recommended for most tasks)
codex exec --sandbox workspace-write "refactor auth module"

# Full access (dangerous - use carefully)
codex exec --sandbox danger-full-access "update system configs"
```

**Spawning from other agents:**
```bash
# From Claude or Gemini, use Codex for autonomous refactoring
codex exec --sandbox workspace-write --full-auto "Add comprehensive tests to src/auth/"

# Complex multi-file refactoring (uses default model to avoid errors)
codex exec --config model_reasoning_effort="high" \
  --sandbox workspace-write "Migrate from REST to GraphQL"
```

### OpenCode CLI

**Basic Usage:**
```bash
# Interactive mode
opencode

# With specific agent
opencode --agent architect

# Non-interactive (if supported)
opencode -p "your prompt"
```

### Cross-Invocation Patterns

**Pattern 1: Claude orchestrates, Gemini analyzes**
```bash
# In Claude, spawn Gemini for large-scale analysis
gemini -p "Analyze all 500+ files for security issues: @src/ @lib/ @tests/"
# Then use results in Claude for remediation planning
```

**Pattern 2: Claude orchestrates, Codex implements**
```bash
# In Claude, spawn Codex for autonomous implementation
codex exec --sandbox workspace-write --full-auto \
  "Implement the auth refactoring plan documented in docs/auth-refactor.md"
```

**Pattern 3: Gemini analyzes, Claude reasons, Codex implements**
```bash
# Step 1: Gemini analyzes (from any agent)
gemini -p "Identify all technical debt in: @src/" > /tmp/tech-debt.md

# Step 2: Claude prioritizes (from any agent)
claude -p "Prioritize this technical debt list: $(cat /tmp/tech-debt.md)"

# Step 3: Codex implements (from any agent)
codex exec --sandbox workspace-write "Fix top priority: ..."
```

**Pattern 4: Parallel agent execution**
```bash
# Run multiple analyses in parallel
gemini -p "Security audit: @src/" &
claude -p "Architecture review of: $(cat src/main.py)" &
wait
```

### Best Practices for Cross-Invocation

1. **Use the right tool for the job:**
   - Gemini: Large context analysis (>100K tokens), codebase-wide searches
   - Claude: Complex reasoning, nuanced decisions, code generation
   - Codex: Autonomous multi-step implementation, refactoring

2. **Prefer non-interactive modes** (`-p` flag) for predictable automation

3. **Capture output** for downstream processing:
   ```bash
   ANALYSIS=$(gemini -p "analyze @src/")
   claude -p "Based on this analysis: $ANALYSIS, recommend next steps"
   ```

4. **Use appropriate sandbox modes** in Codex for safety

5. **Chain tools sequentially** when output of one informs the next

## Task Completion Summaries

When completing any task, agents MUST provide a well-formatted, comprehensive summary with the following structure:

### Summary Format

**What Was Done:**
- Clear, detailed bullet points explaining each change made
- Include file paths and specific modifications
- Explain the reasoning behind technical decisions

**Impact:**
- What functionality changed or was added
- What benefits this provides to the system
- Any breaking changes or backwards compatibility notes
- Performance implications if relevant

**Tests Completed:**
- List all tests that were run and their results
- Include specific test commands used
- Note any test failures and how they were addressed
- Coverage metrics if applicable

**Verification Needed:**
- Clear checklist of items for the user to verify
- Specific commands to run for manual testing
- Edge cases or scenarios to check
- Any configuration or environment changes needed

**Follow-Up Needed:**
- **REQUIRED:** Always include this section to explicitly state what action is needed from the user
- If task is complete and nothing is needed: "Task complete - no further action required"
- If user action is needed: Use clear, actionable bullet points to highlight priority
- Be explicit about what will unblock or complete the work

**TLDR:**
- **REQUIRED:** Executive summary in a single, highly readable paragraph
- Capture the complete situation: what was done, why it matters, current status, and what's next
- Focus on business/system impact rather than technical details
- Use clear, concise language (2-3 sentences maximum)

### Formatting Guidelines
- Use proper markdown headers (###, ####)
- Use bullet points for lists, not just commas
- Include code blocks with syntax highlighting when showing commands or code
- Keep paragraphs readable (max 2-3 sentences)
- Use **bold** for important items and key outcomes
- Use `code formatting` for file paths, commands, and technical terms
- Structure summaries with clear visual hierarchy

---

## Infrastructure Configuration

> **This section is a template.** Replace the placeholders below with your actual
> infrastructure details. Delete any sections that don't apply to your setup.

### Deployment Standards

When deploying ANY project, agents MUST follow these standards:

**1. Security Requirements:**
- **NEVER** run services as root - always use a dedicated deploy user
- **ALWAYS** bind services to `127.0.0.1` only (not `0.0.0.0`)
- **ALWAYS** use a reverse proxy (Nginx/Caddy) for public traffic
- **NEVER** expose app ports directly to the internet

**2. Process Management:**
- **USE** systemd for all services (not PM2, supervisor, or nohup)
- Services must specify a non-root `User=` and `Group=`
- Use `Restart=on-failure` for automatic recovery
- **ALWAYS** include crash-loop protection: `StartLimitBurst=5` + `StartLimitIntervalSec=600`
- Use `RestartSec=30` minimum to prevent rapid restart storms

**3. Environment Configuration:**
- **ALWAYS** store env files in a centralized directory (e.g. `/etc/<org>/env/`)
- Symlink project `.env` files to the centralized location
- Set permissions: `chmod 640` and `chown root:<deploy-group>`
- **NEVER** commit env files to git

**4. Database Standards:**
- Create one database per project: `<project>_db`
- Create one user per project: `<project>_user`
- **ALWAYS** add new databases to your backup script

**5. Directory Structure:**
```
/var/www/<project>/           # Application code (owned by deploy user)
/etc/<org>/env/               # Centralized env files
/etc/<org>/backups/           # Database backups
/etc/systemd/system/          # Service definitions
/etc/nginx/sites-available/   # Reverse proxy configs
```

### Server Details

| Field | Value |
|-------|-------|
| **Provider** | `<YOUR_PROVIDER>` (e.g. DigitalOcean, AWS, Hetzner) |
| **IP Address** | `<YOUR_SERVER_IP>` |
| **VPN/Tailscale IP** | `<YOUR_VPN_IP>` (if applicable) |
| **SSH Key** | `~/.ssh/<YOUR_KEY>` |
| **SSH Command** | `ssh -i ~/.ssh/<YOUR_KEY> <user>@<ip>` |
| **OS** | `<YOUR_OS>` (e.g. Ubuntu 22.04) |

### Services

| Service | Port | systemd Unit | Directory | Domain |
|---------|------|--------------|-----------|--------|
| `<service-1>` | `127.0.0.1:<PORT>` | `<service>.service` | `/var/www/<service>` | `<subdomain>.<domain>` |
| `<service-2>` | `127.0.0.1:<PORT>` | `<service>.service` | `/var/www/<service>` | `<subdomain>.<domain>` |

### Service Templates

**Python/FastAPI systemd service:**
```ini
[Unit]
Description=<Project Name> API
After=network.target postgresql.service
StartLimitBurst=5
StartLimitIntervalSec=600

[Service]
Type=simple
User=deploy
Group=deploy
WorkingDirectory=/var/www/<project>
EnvironmentFile=/etc/<org>/env/<project>.prod.env
ExecStart=/var/www/<project>/venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port <PORT>
Restart=on-failure
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Node.js systemd service:**
```ini
[Unit]
Description=<Project Name>
After=network.target postgresql.service
StartLimitBurst=5
StartLimitIntervalSec=600

[Service]
Type=simple
User=deploy
Group=deploy
WorkingDirectory=/var/www/<project>
EnvironmentFile=/etc/<org>/env/<project>.prod.env
Environment=NODE_ENV=production
Environment=HOST=127.0.0.1
ExecStart=/usr/bin/node <start-script>
Restart=on-failure
RestartSec=30
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Nginx reverse proxy template:**
```nginx
server {
    listen 80;
    server_name <subdomain>.<domain>.com;

    location / {
        proxy_pass http://127.0.0.1:<PORT>;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
# After creating: ln -s /etc/nginx/sites-available/<project> /etc/nginx/sites-enabled/
# Then: nginx -t && systemctl reload nginx
# Then: certbot --nginx -d <subdomain>.<domain>.com
```

### Troubleshooting Commands

```bash
# Check service status
systemctl status <project>

# View logs
journalctl -u <project> -f              # Follow live
journalctl -u <project> --since "1h"    # Last hour
journalctl -u <project> -n 100          # Last 100 lines

# Check port binding (should show 127.0.0.1)
ss -tlnp | grep <PORT>

# Check process owner (should be deploy user)
ps aux | grep <project>

# Test health locally
curl http://127.0.0.1:<PORT>/health

# Test through reverse proxy
curl https://<subdomain>.<domain>.com/health

# Restart after config changes
systemctl daemon-reload
systemctl restart <project>
```
