#!/bin/bash
# Setup AI agent configuration for a project directory
#
# Creates symlinks from each CLI's config location to a shared PROJECT-AGENTS.md
# file, so all agents read the same project-level instructions.
#
# Usage:
#   ./setup-project.sh                    # Setup in current directory
#   ./setup-project.sh /path/to/project   # Setup in specified directory
#   ./setup-project.sh --dry-run          # Preview changes
#   ./setup-project.sh --remove           # Remove agent symlinks

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $1"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
err()   { echo -e "${RED}[err]${NC}   $1"; }

DRY_RUN=false
REMOVE=false
PROJECT_DIR=""

# Parse arguments
for arg in "$@"; do
    case "$arg" in
        --dry-run)  DRY_RUN=true ;;
        --remove)   REMOVE=true ;;
        --help|-h)
            echo "Usage: $0 [--dry-run] [--remove] [project-dir]"
            echo ""
            echo "  --dry-run    Preview changes without making them"
            echo "  --remove     Remove agent symlinks from the project"
            echo "  project-dir  Path to the project (default: current directory)"
            exit 0
            ;;
        -*)
            err "Unknown flag: $arg"
            exit 1
            ;;
        *)
            PROJECT_DIR="$arg"
            ;;
    esac
done

# Default to current directory
if [ -z "$PROJECT_DIR" ]; then
    PROJECT_DIR="$(pwd)"
fi

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

info "Project: $PROJECT_DIR"

if $DRY_RUN; then
    warn "DRY RUN - no changes will be made"
    echo ""
fi

# Check for PROJECT-AGENTS.md
if [ ! -f "$PROJECT_DIR/PROJECT-AGENTS.md" ] && ! $REMOVE; then
    warn "No PROJECT-AGENTS.md found in $PROJECT_DIR"
    echo ""
    echo "Create one by copying the template:"
    echo "  cp project-level/PROJECT-AGENTS.md.example $PROJECT_DIR/PROJECT-AGENTS.md"
    echo ""
    echo "Then re-run this script."
    exit 1
fi

# Remove mode
if $REMOVE; then
    info "Removing agent symlinks..."

    for link in \
        "$PROJECT_DIR/.claude/CLAUDE.md" \
        "$PROJECT_DIR/.codex/AGENTS.md" \
        "$PROJECT_DIR/.opencode/AGENTS.md" \
        "$PROJECT_DIR/GEMINI.md"; do
        if [ -L "$link" ]; then
            if $DRY_RUN; then
                info "Would remove: $link"
            else
                rm "$link"
                ok "Removed: $link"
            fi
        fi
    done

    # Clean up empty directories
    for dir in "$PROJECT_DIR/.claude" "$PROJECT_DIR/.codex" "$PROJECT_DIR/.opencode"; do
        if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
            if $DRY_RUN; then
                info "Would remove empty dir: $dir"
            else
                rmdir "$dir"
                ok "Removed empty dir: $dir"
            fi
        fi
    done

    echo ""
    ok "Agent symlinks removed."
    exit 0
fi

# Create symlinks
echo ""
info "Setting up agent symlinks..."
echo ""

# Claude Code: .claude/CLAUDE.md → ../PROJECT-AGENTS.md
CLAUDE_DIR="$PROJECT_DIR/.claude"
CLAUDE_LINK="$CLAUDE_DIR/CLAUDE.md"
if [ -e "$CLAUDE_LINK" ] || [ -L "$CLAUDE_LINK" ]; then
    warn "Already exists: $CLAUDE_LINK (skipping)"
else
    if $DRY_RUN; then
        info "Would create: $CLAUDE_LINK → ../PROJECT-AGENTS.md"
    else
        mkdir -p "$CLAUDE_DIR"
        ln -s ../PROJECT-AGENTS.md "$CLAUDE_LINK"
        ok "Created: $CLAUDE_LINK → ../PROJECT-AGENTS.md"
    fi
fi

# Codex: .codex/AGENTS.md → ../PROJECT-AGENTS.md
CODEX_DIR="$PROJECT_DIR/.codex"
CODEX_LINK="$CODEX_DIR/AGENTS.md"
if [ -e "$CODEX_LINK" ] || [ -L "$CODEX_LINK" ]; then
    warn "Already exists: $CODEX_LINK (skipping)"
else
    if $DRY_RUN; then
        info "Would create: $CODEX_LINK → ../PROJECT-AGENTS.md"
    else
        mkdir -p "$CODEX_DIR"
        ln -s ../PROJECT-AGENTS.md "$CODEX_LINK"
        ok "Created: $CODEX_LINK → ../PROJECT-AGENTS.md"
    fi
fi

# OpenCode: .opencode/AGENTS.md → ../PROJECT-AGENTS.md
OPENCODE_DIR="$PROJECT_DIR/.opencode"
OPENCODE_LINK="$OPENCODE_DIR/AGENTS.md"
if [ -e "$OPENCODE_LINK" ] || [ -L "$OPENCODE_LINK" ]; then
    warn "Already exists: $OPENCODE_LINK (skipping)"
else
    if $DRY_RUN; then
        info "Would create: $OPENCODE_LINK → ../PROJECT-AGENTS.md"
    else
        mkdir -p "$OPENCODE_DIR"
        ln -s ../PROJECT-AGENTS.md "$OPENCODE_LINK"
        ok "Created: $OPENCODE_LINK → ../PROJECT-AGENTS.md"
    fi
fi

# Gemini CLI: GEMINI.md → PROJECT-AGENTS.md
GEMINI_LINK="$PROJECT_DIR/GEMINI.md"
if [ -e "$GEMINI_LINK" ] || [ -L "$GEMINI_LINK" ]; then
    warn "Already exists: $GEMINI_LINK (skipping)"
else
    if $DRY_RUN; then
        info "Would create: $GEMINI_LINK → PROJECT-AGENTS.md"
    else
        ln -s PROJECT-AGENTS.md "$GEMINI_LINK"
        ok "Created: $GEMINI_LINK → PROJECT-AGENTS.md"
    fi
fi

# Update .gitignore
GITIGNORE="$PROJECT_DIR/.gitignore"
AGENT_ENTRIES=(".claude/" ".codex/" ".opencode/" "GEMINI.md")
NEEDS_UPDATE=false

for entry in "${AGENT_ENTRIES[@]}"; do
    if [ -f "$GITIGNORE" ]; then
        if ! grep -qF "$entry" "$GITIGNORE"; then
            NEEDS_UPDATE=true
            break
        fi
    else
        NEEDS_UPDATE=true
        break
    fi
done

if $NEEDS_UPDATE; then
    if $DRY_RUN; then
        info "Would add agent entries to $GITIGNORE"
    else
        echo "" >> "$GITIGNORE"
        echo "# AI agent config (symlinks to PROJECT-AGENTS.md)" >> "$GITIGNORE"
        for entry in "${AGENT_ENTRIES[@]}"; do
            if ! grep -qF "$entry" "$GITIGNORE" 2>/dev/null; then
                echo "$entry" >> "$GITIGNORE"
            fi
        done
        ok "Updated .gitignore with agent entries"
    fi
fi

# Verify
echo ""
info "Verifying..."
for link in "$CLAUDE_LINK" "$CODEX_LINK" "$OPENCODE_LINK" "$GEMINI_LINK"; do
    if [ -L "$link" ]; then
        ok "$link → $(readlink "$link")"
    elif [ -e "$link" ]; then
        warn "$link exists but is not a symlink"
    else
        if ! $DRY_RUN; then
            err "$link missing"
        fi
    fi
done

echo ""
ok "Project setup complete!"
echo ""
info "All four CLIs will now read from: PROJECT-AGENTS.md"
info "Edit PROJECT-AGENTS.md to customize agent behavior for this project."
