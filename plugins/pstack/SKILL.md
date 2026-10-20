---
name: maestri-pstack
description: Run pstack engineering workflows from a Maestri Maestro terminal, using connected agent presets for delegation and multi-model review. Use for pstack, poteto-mode, interrogate, arena, swarm, or setup-pstack in Maestri.
---

# Maestri pstack

This skill is the entry point for Lauren Tan's pstack in a Maestri Maestro terminal. The `skills/` directory is a pinned copy of the [Cursor pstack](https://github.com/cursor/plugins/tree/main/pstack) skills. Keep their workflow and engineering guidance; use `MAESTRI.md` for the execution surface.

1. Read `MAESTRI.md` in this skill's directory before opening an upstream skill. It defines how Cursor tools, models, subagents, and paths work in Maestri. Its Maestri mappings take precedence over Cursor-specific instructions in the copied skills.
2. For setup or model choices, read `setup/SKILL.md`. For a named pstack skill, read `skills/<name>/SKILL.md`. For an ordinary task, read `skills/poteto-mode/SKILL.md` and let it select a playbook.
3. Follow the selected skill and its referenced files. When it calls another pstack skill, read it under this package's `skills/` directory. Resolve references relative to the file that names them.
4. Before the first dispatch in a session, validate `~/.config/maestri-pstack/presets.json` with `scripts/validate_config.py <path> --live` if the file exists. Read the applicable role and use the dispatch procedure in `MAESTRI.md`. If validation fails, repair the configuration through `setup/SKILL.md` before recruiting.
5. Verify the result through the selected workflow's checks. Report what ran and any unsupported step accurately.

The package does not require the recruited agent to have this skill installed. Give it the absolute paths to the relevant skill, persona, and checkout in its brief.
