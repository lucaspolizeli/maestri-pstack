# CONTEXT - the Maestri form

maestri-pstack is Lauren Tan's pstack with its Cursor mechanics rewritten for Maestri, on Claude Code. The skill text stays Lauren's. Only what names a Cursor mechanism changes, and it changes into the form below. Every rewritten file follows this page.

## Glossary

- **Host** - Claude Code running in a Maestri terminal. v1 supports no other host.
- **Plugin root** - the directory two levels above a skill's base directory: the installed copy of `plugins/pstack/`, which holds `CONTEXT.md` and `models.json`. Skills write it as `<plugin root>`.
- **Model sheet** - `~/.config/maestri-pstack/models.md`, one role per line. `/setup-pstack` writes it. A role with no line keeps the default in its skill's Models section.
- **Sheet value** - one of:
  - a Claude alias with an optional effort: `opus`, `sonnet @high`, `fable @xhigh`;
  - a Maestri preset: `preset:"Codex"`, a name `maestri preset list` prints;
  - `inherit-parent`: run on the parent chat's model.
  A panel role takes a comma-separated list, and a list may mix aliases and presets.
- **Local dispatch** - Claude Code's `Agent` tool with `subagent_type: "maestri-pstack:poteto-agent"` (or the persona a skill names), `run_in_background: true`, `model` set to the alias, and `effort` set to the alias's `@effort` when the sheet names one. It runs inside this chat and is not on the canvas.
- **Canvas dispatch** - a Maestri teammate: `maestri recruit "<codename>" --preset "<preset>" --role "poteto-agent"`, then `maestri ask "<codename>" "<brief>"`. The brief ends with the ask back line, `maestri ask "<your name>" "<result>"`, so the result comes back in full.
- **Recruit** - a teammate made by canvas dispatch. It holds a terminal slot and a model session.
- **Floor** - a Maestri level backed by a git worktree, made with `maestri floor create`. It replaces the upstream "one worktree per delegate".
- **Persona** - an agent file under `<plugin root>/agents/`. On local dispatch it is the `subagent_type`. On canvas dispatch, `/setup-pstack` creates the Maestri role `poteto-agent`, whose prompt tells the recruit to read `<plugin root>/agents/poteto-agent.md` first.

## Default models

`plugins/pstack/models.json` holds the role defaults. Each skill's Models section repeats the defaults for its own roles.

| Tier | Value | Upstream tier it replaces |
|---|---|---|
| code | `opus` | the fast code model (grok) |
| strongest | `fable` | the strongest judgment model |
| judgment | `opus` | prose and judgment (opus) |
| verify | `sonnet` | swarm workers and verification |
| panel | `opus, preset:"Codex"` | the cross-family panel (opus / grok) |

A panel must span two model families, so its second member is a Maestri preset.

**Panel fallback.** When a panel member is a preset that cannot run (`maestri preset list` does not print it, or this terminal is not the Maestro), replace it with the first Claude alias not already in the panel: `sonnet`, then `opus`, then `fable`. Say once that the panel has only one family. The skills point here instead of restating the rule.

## Choosing the dispatch

Canvas dispatch needs Maestro Mode. Only the Maestro terminal can run `maestri recruit`, `maestri preset list`, `maestri role`, `maestri floor create`, `maestri floor list` and `maestri routine`. Any terminal can run `maestri list`, `maestri ask`, `maestri check`, `maestri note` and `maestri floor status`. Check once per chat: run `maestri preset list`. If it fails with "This terminal is not the Maestro", this chat has no canvas dispatch. Say so once, and use these fallbacks:

- Every subagent runs local. A delegate that writes files gets `isolation: "worktree"` on its `Agent` call in place of a floor.
- A panel member on a preset follows the panel fallback above.
- A fixed-cadence routine becomes Claude Code's `/loop <interval>`.
- Work that must outlive the turn goes to the user, who can run it from the Maestro terminal.

The orchestrate, autopilot-full and multi-phase-plan playbooks have no fallback. Their programs run for days, recover from restarts through floors, and arm their audit as a routine, and a local subagent or `/loop` dies with the chat. Outside the Maestro they stop and ask the user to start them from the Maestro terminal.

When this terminal is the Maestro, use the role's sheet value, and check these rules in order:

1. The delegate writes files. Use canvas dispatch onto its own floor: `maestri floor create "<task>"`, then `maestri recruit "<codename>" --floor "<task>" ...`. This applies even when the role names a Claude alias. The recruit then runs `claude --model <alias>` through a preset that matches the alias, or a copy of the parent if no preset matches.
2. The work must outlive this turn (a PR watcher, a dev server, a simulator). Use canvas dispatch.
3. The value is a preset. Use canvas dispatch.
4. In all other cases (a short task, a read-only task, a Claude alias), use local dispatch.

A panel dispatches each member by these rules and runs them in parallel. Local members run as background `Agent` calls. Canvas members run through one `maestri ask --batch`.

## Fresh agents and reuse

Upstream says to give new work to a fresh subagent. Maestri says to reuse a teammate before recruiting a new one. Both rules hold:

- Run `maestri list` before you recruit. If a teammate already holds the role, give it the new work with `maestri recruit --replace "<codename>"` and the same preset. The process restarts with a clean context. The terminal, its connections, and its floor stay.
- Resume a teammate without `--replace` only where upstream allows reuse: the work needs that agent's checkout, its uncommitted changes, or a process it runs.

## Other Cursor mechanisms

| Upstream | Maestri form |
|---|---|
| `/loop <interval>`, a fixed cadence (audit ticks) | `maestri routine create "<name>" --command "<tick prompt>" --every <interval>`, aimed at your own terminal. A routine needs Maestro Mode. |
| `/loop` until a check passes | Claude Code's `/loop` without an interval, which paces itself until the predicate holds. |
| A watcher that wakes you on an event (CI, a merge, a ref advancing) | `maestri routine create ... --every 5m --count 1 --pre-run "<script that exits 0 only once the event happened>"`. The routine fires only when the gate passes. |
| Cloud agents, background VMs | Recruits on floors. |
| `AskQuestion` | `AskUserQuestion`. When the run waits on the user, also post `maestri floor status "<what you need>" --state blocked`. |
| `agent-transcripts` | Claude Code transcripts under `~/.claude/projects/<project>/*.jsonl`, and `maestri check "<codename>"` for a live teammate. |
| `readonly` / Ask mode | One sentence in the brief: "Do not edit files." |
| `control-ui`, `control-cli` | The project's verification skill, or `maestri portal` for web and `maestri portal` on a device portal for mobile. |
| `/visualize`, canvases | `maestri note create --name "<name>"` with markdown. |
| `.cursor/rules/pstack-models.mdc` | The model sheet. |
| `/create-skill` | Claude Code's skill-authoring skill. |
| `/add-plugin pstack` | The install steps in the README. |

## Floor status

A recruit that works on a floor keeps that floor's status current with `maestri floor status`. It posts when it starts, at a real milestone, with `--state blocked` when it needs the user, and with `--state review` when the work is ready. The coordinator reads `maestri floor list` before it checks each recruit.

## Safety

Only run these after the user explicitly asks or confirms: `maestri floor land`, `maestri floor delete`, `maestri dismiss`, `maestri routine delete`, `maestri note delete`, `maestri portal close`. A floor in `review` is ready for the user to decide. It is not a signal to land it. GitHub merges in the shipping playbooks follow Lauren's rules unchanged.
