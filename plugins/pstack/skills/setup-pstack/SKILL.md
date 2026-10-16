---
name: setup-pstack
description: Configure which models pstack uses per role and at what reasoning budget. Detects your Claude models and Maestri presets and writes a model sheet that overrides the skill defaults. Use for /setup-pstack, "configure pstack models", "pstack budget", or changing pstack's model choices.
---

# Setup pstack

Write `~/.config/maestri-pstack/models.md`, the model sheet that sets pstack's model per role, and make sure the Maestri role `poteto-agent` exists.

## Steps

### 1. Detect available models

Two sources are dependable:

- The Claude aliases you can pass as `model` to a local `Agent` subagent in this session: `opus`, `fable`, `sonnet`, `haiku`.
- The Maestri presets that `maestri preset list` prints. Each one is a valid `preset:"Name"` value, such as `preset:"Codex"`.

If you cannot detect either, ask the user to paste what they have access to. Never write an alias or a preset you have not confirmed is available. The value `inherit-parent` is always valid even though it is not detected.

### 2. Load current state

The default role-to-model mapping is the sheet shape shown in step 5 below. It comes from the tiers in `<plugin root>/models.json`. If `~/.config/maestri-pstack/models.md` already exists, read it and treat its `# budget` line and its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it.

### 3. Budget, map, and confirm

**(a) Ask for a budget.** Prefer AskUserQuestion over free text. Offer these four options with these exact labels, and name the current budget when the sheet records one. With no sheet, say that `large` matches the skill defaults.

- `unlimited — max reasoning`
- `large — xhigh reasoning`
- `medium — high reasoning`
- `small — medium reasoning`

**(b) Apply it.** Build the working table from the skill defaults, and on a re-run keep any role you changed by family, list, preset, or `inherit-parent`. `unlimited`, `large`, `medium`, and `small` set the effort of every Claude alias, panel entries included, to `@max`, `@xhigh`, `@high`, or `@medium`, on the ladder `max` > `xhigh` > `high` > `medium` > `low`. So `unlimited` turns `opus` into `opus @max`, and `small` turns it into `opus @medium`. A preset does not change, because its effort lives in the preset's own command. `inherit-parent` does not change either.

**(c) Show the roles and confirm.** Show every role with its value, marking any alias or preset not in the detected set as needing a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the detected aliases, the detected presets, and `inherit-parent` (the role runs on the parent chat model) as the options. Prefer AskUserQuestion over free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, so the list length sets the count. A panel must span two model families. Its default is `opus, preset:"Codex"`. When `maestri preset list` has no `Codex` preset, offer another detected preset from a different family, or fall back to `opus, sonnet` and say once that the panel then has only one family. `arena cross-judge pool` is also a list, but Arena selects one value from it whose model family differs from the parent's when possible. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every alias and preset written must be in the detected set. `inherit-parent` always passes. If a chosen value is not available, stop and ask again.

### 5. Write the sheet

Write `~/.config/maestri-pstack/models.md` with a `# budget` line with the chosen label and its target effort, and one line per role, using the same labels poteto-mode uses. Create the directory if it is missing. Overwrite the whole file so re-runs stay idempotent. Shape, with the `large` budget:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# Values: a Claude alias with an optional @effort (local dispatch), preset:"Name" (canvas dispatch), or inherit-parent (the parent chat model). Every entry in a panel list counts toward its fan-out.
# budget: large (xhigh)
feature, refactoring: opus @xhigh
bug-fix: opus @xhigh
perf-issue: opus @xhigh
hillclimb: opus @xhigh
judgment and prose: opus @xhigh
hardest tasks: fable @xhigh
how explorer: opus @xhigh
how explainer: opus @xhigh
why investigators: opus @xhigh
why synthesizer: opus @xhigh
reflect tooling: opus @xhigh
reflect judgment, divergent, synthesizer: opus @xhigh
arena runners: opus @xhigh, preset:"Codex"
arena cross-judge pool: opus @xhigh, preset:"Codex"
swarm workers: sonnet @xhigh
architect runners: opus @xhigh, preset:"Codex"
interrogate reviewers: opus @xhigh, preset:"Codex"
```

### 6. Create the poteto-agent role

Canvas dispatch recruits teammates with `--role "poteto-agent"`. Run `maestri role list`. If it has no `poteto-agent` role, create it:

```
maestri role create "poteto-agent" "Before any work, read <plugin root>/agents/poteto-agent.md in full and follow it. Run \`maestri list\` to see your connected teammates and shared notes before you ask anyone anything. When your brief names an ask back line, send your result with it when you are done." --scope global
```

Write the real plugin root path in place of `<plugin root>`. If the role exists, leave it as it is.

### 7. Confirm

Tell the user the sheet was written and that it applies to new sessions. Re-running this skill updates it.

### 8. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with /create-verification-skill." On yes, invoke `/create-verification-skill` (resolves wherever pstack is installed: project, user, or plugin). On no, move on without pushing.
