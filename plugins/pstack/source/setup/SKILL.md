---
name: setup-maestri-pstack
description: Configure Maestri presets and model families for pstack roles, and create the four Maestri recruit roles. Use when setting up or changing pstack agents.
---

# Set up Maestri pstack

Read `../../MAESTRI.md` first. This setup runs from a Maestro terminal and writes `~/.config/maestri-pstack/presets.json`. It does not create or change Maestri presets; the user manages those in Maestri.

1. Run `maestri list`, `maestri preset list`, and `maestri role list`. Confirm `maestro: true` and record the exact available preset names. Read the existing JSON file if it exists. Preserve valid user choices on a rerun.
2. Ask which available preset should run each role group. Let the user choose one default for code (`feature, refactoring`, `bug-fix`, `perf-issue`, `hillclimb`), one for difficult work, one for judgment, and one for verification, then offer overrides for individual roles. `inherit-parent` is valid for every single-worker role. Do not assume a CLI or model is available merely because its company or model name was mentioned.
3. Ask for the actual model family behind each preset used. Build `arena runners` and `architect runners` with at least two seats; their candidates may share a family for generation-heavy work. Build `interrogate reviewers` from at least two explicit presets of different families; `inherit-parent` cannot prove diversity at setup time. For `arena cross-judge pool`, record one or more available choices for later selection. A panel's list length is its seat count. Never claim diversity when the families match.
4. Write a UTF-8 JSON object with exactly `families` and `roles`. `families` maps preset names to lowercase family labels. `roles` maps every label listed in `MAESTRI.md` to either one preset name, `inherit-parent`, or an array for `arena runners`, `arena cross-judge pool`, `architect runners`, and `interrogate reviewers`. Example:

   ```json
   {
     "families": {"Claude Code": "claude", "Codex": "openai"},
     "roles": {
       "feature, refactoring": "Codex",
       "bug-fix": "Codex",
       "perf-issue": "Codex",
       "hillclimb": "Codex",
       "hardest tasks": "Claude Code",
       "judgment and prose": "Claude Code",
       "how explorer": "Codex",
       "how explainer": "Claude Code",
       "why investigators": "Codex",
       "why synthesizer": "Claude Code",
       "reflect tooling": "Codex",
       "reflect judgment, divergent, synthesizer": "Claude Code",
       "swarm workers": "Codex",
       "arena runners": ["Claude Code", "Codex"],
       "arena cross-judge pool": ["Claude Code", "Codex"],
       "architect runners": ["Claude Code", "Codex"],
       "interrogate reviewers": ["Claude Code", "Codex"]
     }
   }
   ```

5. Validate every preset name against `maestri preset list` and every family as a lowercase label before replacing an existing file. Use `scripts/validate_config.py <path> --live` from this package to check the complete role map and panel requirements. Write to a temporary file in the same directory, validate it, then rename it over `presets.json`.
6. For each role prompt in `MAESTRI.md`, compare it with `maestri role show "<name>"` if the role exists. Create a missing role with `maestri role create "<name>" "<prompt>" --scope global`. Update a differing existing role with `maestri role write "<name>" "<prompt>"`. Do not change unrelated roles.
7. Report the selected presets and families, and state which Maestri roles were created or updated. A new run reads the file at dispatch time; no terminal restart is needed.

If a desired Grok, Kimi, GLM, or other agent is absent from `maestri preset list`, explain that Maestri needs a preset for its runnable CLI. Do not invent its command or create a preset without knowing the user's installed CLI and account.
