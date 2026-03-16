#!/bin/bash
# Install multi-cli-agent-setup
#
# Creates symlinks and copies for AI coding agent configuration across
# Claude Code, Codex, Gemini CLI, and OpenCode.
#
# Usage:
#   ./install.sh --all                   # Install everything
#   ./install.sh --agents                # Install AGENTS.md (full template)
#   ./install.sh --agents-minimal        # Install AGENTS-minimal.md as AGENTS.md
#   ./install.sh --templates             # Copy CLI config templates
#   ./install.sh --skills                # Install skills to detected CLIs
#   ./install.sh --commands              # Install commands to detected CLIs
#   ./install.sh --project /path/to/dir  # Setup project-level symlinks
#   ./install.sh --dry-run --all         # Preview all changes
#   ./install.sh --uninstall             # Remove everything and restore backups

set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
UNINSTALL=false
BACKUP_SUFFIX=".bak.$(date +%Y%m%d%H%M%S)"

# What to install (default: nothing, must specify flags)
INSTALL_AGENTS=false
INSTALL_AGENTS_MINIMAL=false
INSTALL_TEMPLATES=false
INSTALL_SKILLS=false
INSTALL_COMMANDS=false
PROJECT_PATH=""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${BLUE}[info]${NC}  $1"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $1"; }
err()   { echo -e "${RED}[err]${NC}   $1"; }
header() { echo -e "\n${CYAN}── $1 ──${NC}\n"; }

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            INSTALL_AGENTS=true
            INSTALL_TEMPLATES=true
            INSTALL_SKILLS=true
            INSTALL_COMMANDS=true
            ;;
        --agents)          INSTALL_AGENTS=true ;;
        --agents-minimal)  INSTALL_AGENTS_MINIMAL=true ;;
        --templates)       INSTALL_TEMPLATES=true ;;
        --skills)          INSTALL_SKILLS=true ;;
        --commands)        INSTALL_COMMANDS=true ;;
        --project)
            shift
            if [[ $# -eq 0 ]]; then
                err "--project requires a path argument"
                exit 1
            fi
            PROJECT_PATH="$1"
            ;;
        --dry-run)   DRY_RUN=true ;;
        --uninstall) UNINSTALL=true ;;
        --help|-h)
            echo "Usage: $0 [flags]"
            echo ""
            echo "Install flags (combine as needed):"
            echo "  --all              Install agents + templates + skills + commands"
            echo "  --agents           Install full AGENTS.md to ~/.agents-global/"
            echo "  --agents-minimal   Install minimal AGENTS.md to ~/.agents-global/"
            echo "  --templates        Copy CLI config examples to each CLI's config dir"
            echo "  --skills           Install skills to detected CLIs"
            echo "  --commands         Install commands to detected CLIs"
            echo "  --project <path>   Setup project-level symlinks in <path>"
            echo ""
            echo "Options:"
            echo "  --dry-run          Preview changes without making them"
            echo "  --uninstall        Remove installed files and restore backups"
            echo "  --help, -h         Show this help"
            exit 0
            ;;
        *)
            err "Unknown argument: $1 (use --help for usage)"
            exit 1
            ;;
    esac
    shift
done

# Validate: something must be selected
if ! $INSTALL_AGENTS && ! $INSTALL_AGENTS_MINIMAL && ! $INSTALL_TEMPLATES && \
   ! $INSTALL_SKILLS && ! $INSTALL_COMMANDS && ! $UNINSTALL && [ -z "$PROJECT_PATH" ]; then
    err "No install target specified. Use --all or pick specific flags."
    echo "Run: $0 --help"
    exit 1
fi

# Cannot use both --agents and --agents-minimal
if $INSTALL_AGENTS && $INSTALL_AGENTS_MINIMAL; then
    err "Cannot use both --agents and --agents-minimal"
    exit 1
fi

# Platform detection
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

PLATFORM=$(detect_platform)
info "Platform: $PLATFORM"
info "Repo: $REPO_DIR"

if $DRY_RUN; then
    warn "DRY RUN - no changes will be made"
fi

# Detect installed CLIs
HAS_CLAUDE=false
HAS_CODEX=false
HAS_GEMINI=false
HAS_OPENCODE=false

command -v claude   >/dev/null 2>&1 && HAS_CLAUDE=true
command -v codex    >/dev/null 2>&1 && HAS_CODEX=true
command -v gemini   >/dev/null 2>&1 && HAS_GEMINI=true
command -v opencode >/dev/null 2>&1 && HAS_OPENCODE=true

echo ""
info "Detected CLIs:"
$HAS_CLAUDE  && ok "  Claude Code" || warn "  Claude Code (not found)"
$HAS_CODEX   && ok "  Codex"       || warn "  Codex (not found)"
$HAS_GEMINI  && ok "  Gemini CLI"  || warn "  Gemini CLI (not found)"
$HAS_OPENCODE && ok "  OpenCode"   || warn "  OpenCode (not found)"

# CLI config directories
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"
GEMINI_DIR="$HOME/.gemini"
OPENCODE_DIR="$HOME/.config/opencode"
AGENTS_GLOBAL_DIR="$HOME/.agents-global"

# Helpers
backup_if_exists() {
    local target="$1"
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ]; then
            local link_target
            link_target=$(readlink "$target")
            if [[ "$link_target" == "$REPO_DIR"* ]] || [[ "$link_target" == "$AGENTS_GLOBAL_DIR"* ]]; then
                info "Already linked: $target"
                return 1
            fi
        fi
        local backup="${target}${BACKUP_SUFFIX}"
        if $DRY_RUN; then
            info "Would backup: $target → $backup"
        else
            cp -a "$target" "$backup"
            ok "Backed up: $target → $backup"
        fi
    fi
    return 0
}

create_link() {
    local source="$1"
    local target="$2"
    if $DRY_RUN; then
        info "Would link: $target → $source"
        return
    fi
    mkdir -p "$(dirname "$target")"
    ln -sf "$source" "$target"
    ok "Linked: $target → $source"
}

copy_file() {
    local source="$1"
    local target="$2"
    if [ -e "$target" ]; then
        info "Already exists: $target (skipping)"
        return
    fi
    if $DRY_RUN; then
        info "Would copy: $source → $target"
        return
    fi
    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
    ok "Copied: $target"
}

copy_dir() {
    local source="$1"
    local target="$2"
    if [ -d "$target" ]; then
        info "Already exists: $target (skipping)"
        return
    fi
    if $DRY_RUN; then
        info "Would copy dir: $source → $target"
        return
    fi
    mkdir -p "$(dirname "$target")"
    cp -r "$source" "$target"
    ok "Copied dir: $target"
}

# ─── Uninstall ───────────────────────────────────────────────────────────────

if $UNINSTALL; then
    header "Uninstalling"

    # Remove AGENTS.md symlinks
    for link in \
        "$CLAUDE_DIR/CLAUDE.md" \
        "$CODEX_DIR/AGENTS.md" \
        "$OPENCODE_DIR/AGENTS.md" \
        "$GEMINI_DIR/GEMINI.md"; do
        if [ -L "$link" ]; then
            local_target=$(readlink "$link")
            if [[ "$local_target" == *"agents-global"* ]] || [[ "$local_target" == "$AGENTS_GLOBAL_DIR"* ]]; then
                if $DRY_RUN; then
                    info "Would remove: $link"
                else
                    rm "$link"
                    ok "Removed: $link"
                fi

                # Restore backup
                local_backup=$(find "$(dirname "$link")" -maxdepth 1 -name "$(basename "$link").bak.*" -print 2>/dev/null | sort -r | head -1 || true)
                if [ -n "$local_backup" ]; then
                    if $DRY_RUN; then
                        info "Would restore: $local_backup"
                    else
                        mv "$local_backup" "$link"
                        ok "Restored: $local_backup → $link"
                    fi
                fi
            fi
        fi
    done

    # Remove agents-global directory if it's ours
    if [ -d "$AGENTS_GLOBAL_DIR" ]; then
        if $DRY_RUN; then
            info "Would remove: $AGENTS_GLOBAL_DIR"
        else
            rm -rf "$AGENTS_GLOBAL_DIR"
            ok "Removed: $AGENTS_GLOBAL_DIR"
        fi
    fi

    # Remove installed skills
    for cli_dir in "$CLAUDE_DIR/skills" "$CODEX_DIR/skills" "$GEMINI_DIR/skills"; do
        for skill_dir in "$cli_dir/code-review-checklist" "$cli_dir/deployment-helper"; do
            if [ -d "$skill_dir" ]; then
                if $DRY_RUN; then
                    info "Would remove: $skill_dir"
                else
                    rm -rf "$skill_dir"
                    ok "Removed: $skill_dir"
                fi
            fi
        done
    done

    # Remove installed commands
    for cmd_file in \
        "$CLAUDE_DIR/commands/example-healthcheck.md" \
        "$CODEX_DIR/commands/example_healthcheck.md" \
        "$GEMINI_DIR/commands/example-healthcheck.toml"; do
        if [ -f "$cmd_file" ]; then
            if $DRY_RUN; then
                info "Would remove: $cmd_file"
            else
                rm "$cmd_file"
                ok "Removed: $cmd_file"
            fi
        fi
    done

    echo ""
    ok "Uninstall complete."
    exit 0
fi

# ─── Install AGENTS.md ──────────────────────────────────────────────────────

if $INSTALL_AGENTS || $INSTALL_AGENTS_MINIMAL; then
    header "Installing AGENTS.md"

    # Determine source file
    if $INSTALL_AGENTS_MINIMAL; then
        AGENTS_SOURCE="$REPO_DIR/agents-global/AGENTS-minimal.md"
        info "Using minimal template"
    else
        AGENTS_SOURCE="$REPO_DIR/agents-global/AGENTS.md"
        info "Using full template"
    fi

    # Create ~/.agents-global/ and copy AGENTS.md
    if $DRY_RUN; then
        info "Would create: $AGENTS_GLOBAL_DIR/AGENTS.md"
    else
        mkdir -p "$AGENTS_GLOBAL_DIR"
        cp "$AGENTS_SOURCE" "$AGENTS_GLOBAL_DIR/AGENTS.md"
        ok "Created: $AGENTS_GLOBAL_DIR/AGENTS.md"
    fi

    # Create symlinks for each detected CLI
    if $HAS_CLAUDE; then
        backup_if_exists "$CLAUDE_DIR/CLAUDE.md" && \
            create_link "$AGENTS_GLOBAL_DIR/AGENTS.md" "$CLAUDE_DIR/CLAUDE.md"
    fi

    if $HAS_CODEX; then
        backup_if_exists "$CODEX_DIR/AGENTS.md" && \
            create_link "$AGENTS_GLOBAL_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md"
    fi

    if $HAS_GEMINI; then
        backup_if_exists "$GEMINI_DIR/GEMINI.md" && \
            create_link "$AGENTS_GLOBAL_DIR/AGENTS.md" "$GEMINI_DIR/GEMINI.md"
    fi

    if $HAS_OPENCODE; then
        backup_if_exists "$OPENCODE_DIR/AGENTS.md" && \
            create_link "$AGENTS_GLOBAL_DIR/AGENTS.md" "$OPENCODE_DIR/AGENTS.md"
    fi
fi

# ─── Install Templates ──────────────────────────────────────────────────────

if $INSTALL_TEMPLATES; then
    header "Installing CLI config templates"

    if $HAS_CLAUDE; then
        copy_file "$REPO_DIR/templates/claude/mcp.json.example" "$CLAUDE_DIR/mcp.json.example"
        copy_file "$REPO_DIR/templates/claude/claude.json.example" "$CLAUDE_DIR/settings.json.example"
    fi

    if $HAS_CODEX; then
        copy_file "$REPO_DIR/templates/codex/config.toml.example" "$CODEX_DIR/config.toml.example"
    fi

    if $HAS_GEMINI; then
        copy_file "$REPO_DIR/templates/gemini/settings.json.example" "$GEMINI_DIR/settings.json.example"
    fi

    if $HAS_OPENCODE; then
        copy_file "$REPO_DIR/templates/opencode/opencode.json.example" "$OPENCODE_DIR/opencode.json.example"
    fi
fi

# ─── Install Skills ─────────────────────────────────────────────────────────

if $INSTALL_SKILLS; then
    header "Installing skills"

    for skill in code-review-checklist deployment-helper; do
        if $HAS_CLAUDE; then
            copy_dir "$REPO_DIR/skills/$skill" "$CLAUDE_DIR/skills/$skill"
        fi

        if $HAS_CODEX; then
            copy_dir "$REPO_DIR/skills/$skill" "$CODEX_DIR/skills/$skill"
        fi

        if $HAS_GEMINI; then
            copy_dir "$REPO_DIR/skills/$skill" "$GEMINI_DIR/skills/$skill"
        fi
    done
fi

# ─── Install Commands ───────────────────────────────────────────────────────

if $INSTALL_COMMANDS; then
    header "Installing commands"

    if $HAS_CLAUDE; then
        copy_file "$REPO_DIR/commands/claude/example-healthcheck.md" "$CLAUDE_DIR/commands/example-healthcheck.md"
    fi

    if $HAS_CODEX; then
        copy_file "$REPO_DIR/commands/codex/example_healthcheck.md" "$CODEX_DIR/commands/example_healthcheck.md"
    fi

    if $HAS_GEMINI; then
        copy_file "$REPO_DIR/commands/gemini/example-healthcheck.toml" "$GEMINI_DIR/commands/example-healthcheck.toml"
    fi
fi

# ─── Project Setup ──────────────────────────────────────────────────────────

if [ -n "$PROJECT_PATH" ]; then
    header "Setting up project: $PROJECT_PATH"

    if $DRY_RUN; then
        bash "$REPO_DIR/project-level/setup-project.sh" --dry-run "$PROJECT_PATH"
    else
        bash "$REPO_DIR/project-level/setup-project.sh" "$PROJECT_PATH"
    fi
fi

# ─── Summary ────────────────────────────────────────────────────────────────

echo ""
header "Summary"

$INSTALL_AGENTS && ok "AGENTS.md (full) installed to ~/.agents-global/"
$INSTALL_AGENTS_MINIMAL && ok "AGENTS.md (minimal) installed to ~/.agents-global/"
$INSTALL_TEMPLATES && ok "CLI config templates copied"
$INSTALL_SKILLS && ok "Skills installed to detected CLIs"
$INSTALL_COMMANDS && ok "Commands installed to detected CLIs"
[ -n "$PROJECT_PATH" ] && ok "Project configured: $PROJECT_PATH"

echo ""
info "Next steps:"
echo "  1. Edit ~/.agents-global/AGENTS.md with your infrastructure details"
echo "  2. Copy and rename .example files to configure each CLI"
echo "  3. Run './project-level/setup-project.sh' in each project directory"
echo ""
