# multi-cli-agent-setup (archived)

This repository moved to
[knowledge-hub/tools/instruction-links](https://github.com/raegislabs/knowledge-hub/tree/main/tools/instruction-links)
on 28 September 2026 and is no longer maintained.

The new version fixes a wiring error here: Codex does not read
`.codex/AGENTS.md`, so the project-level links in this repository gave Codex
no project rules. The replacement makes the root `AGENTS.md` the project
source, which Codex and OpenCode read directly, and links only Claude Code to
it. It also drops Gemini CLI and the bundled command, skill and config
examples.

If you installed from here, run `./install.sh --uninstall` before installing
the new version, or leave the user-level links in place: they point at the
same `~/.agents-global/AGENTS.md` source.
