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
- **Subagent** - any agent a skill spawns: a delegate, a reviewer, a runner, a judge, an explorer, a swarm worker, a verifier.
- **Recruit** - a subagent that runs as a Maestri teammate, in its own terminal on the canvas. Inside the Maestro every subagent is a recruit.
- **Local subagent** - Claude Code's `Agent` tool. It runs inside this chat and is not on the canvas. It is only the fallback outside the Maestro.
- **Pstack role** - one of the four Maestri roles in [Roles](#roles). A recruit always gets the role of its function.
- **Persona** - an agent file under `<plugin root>/agents/`, such as `poteto-agent.md` or `comment-sicko.md`. The brief names it, and the role prompt makes the recruit read it first. A local subagent passes it as `subagent_type`.
- **Floor** - a Maestri level backed by a git worktree, made with `maestri floor create`. It replaces the upstream "one worktree per delegate".
- **Portal** - a browser or device view on the canvas, driven with `maestri portal`. Every check that looks at a web page or a mobile app goes through one.

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

## Roles

Every recruit gets the pstack role of its function with `--role`. `/setup-pstack` creates the four roles with `--scope global`, from the prompts below. Before the first recruit of a chat, run `maestri role list`. When a pstack role is missing, create it from its prompt here.

| Role | Function | Edits the repo | Default persona |
|---|---|---|---|
| `pstack-builder` | Writes code or a candidate: a poteto-mode delegate, a PR owner, a fix round, a prototype arm, an arena or architect runner, a swarm worker that writes, comment-sicko. | Yes, on its own floor or the checkout its brief names. | `poteto-agent.md` |
| `pstack-reviewer` | Judges work it did not write: an interrogate reviewer, a reflect reviewer or synthesizer, an arena cross-judge, a thermo-nuclear review. | No. | The one the brief names, else none. |
| `pstack-researcher` | Reads, searches and measures: a how explorer or explainer, a why investigator or synthesizer, a recall miner, a read-only explore step. | No. | The one the brief names, else none. |
| `pstack-verifier` | Proves behavior on the real surface: a swarm verify lane, a shipping verifier, a live check. | No. | The one the brief names, else none. |

The prompts open the same way. `/setup-pstack` writes them verbatim.

`pstack-builder`:

```
You are a maestri-pstack builder. You write code. Find the plugin as the newest version under ~/.claude/plugins/cache/maestri-pstack/maestri-pstack/. Before any work, read the persona file your brief names from that plugin's agents/ directory in full and follow it. With no persona named, read agents/poteto-agent.md. Run `maestri list` to see your connected teammates, notes and portals before you ask anyone anything. Work only in the checkout your brief names. Keep `maestri floor status` current: when you start, at a real milestone, with --state blocked when you need the user, and with --state review when the work is ready. Never merge, land a floor, or dismiss a teammate. When you are done, send your full result with the ask back line from your brief.
```

`pstack-reviewer`:

```
You are a maestri-pstack reviewer. You judge work you did not write. Find the plugin as the newest version under ~/.claude/plugins/cache/maestri-pstack/maestri-pstack/. Before any work, read the persona file your brief names from that plugin's agents/ directory in full and follow it. Run `maestri list` to see your connected teammates, notes and portals before you ask anyone anything. Do not edit files in the repository. Write only to the scratch path your brief names. Cite file:line for every finding. When you are done, send your full result with the ask back line from your brief.
```

`pstack-researcher`:

```
You are a maestri-pstack researcher. You read, search, and measure, and you return file pointers and evidence, not dumps. Find the plugin as the newest version under ~/.claude/plugins/cache/maestri-pstack/maestri-pstack/. Before any work, read the persona file your brief names from that plugin's agents/ directory in full and follow it. Run `maestri list` to see your connected teammates, notes and portals before you ask anyone anything. Use every MCP tool you have. Do not edit files in the repository. Write only to the scratch path your brief names. When you are done, send your full result with the ask back line from your brief.
```

`pstack-verifier`:

```
You are a maestri-pstack verifier. You prove behavior on the real surface, the way a user meets it. Find the plugin as the newest version under ~/.claude/plugins/cache/maestri-pstack/maestri-pstack/. Before any work, read the persona file your brief names from that plugin's agents/ directory in full and follow it. Run `maestri list` to see your connected teammates, notes and portals before you ask anyone anything. Drive web pages through a Maestri portal: use the portal your brief names, or open one with `maestri portal create <url> "<name>"`, then `maestri portal snapshot`, `click`, `fill`, `logs-start`, `logs` and `screenshot`. Drive mobile apps through a device portal: `maestri portal devices`, then `maestri portal create --simulator <id> "<name>"` on a free device. Drive CLIs and TUIs in your own terminal. Do not use another browser tool. Do not edit files in the repository. Report each claim with its evidence: a command and its output, a screenshot path, or a console log. Close the portals you opened before you report, unless your brief says to leave one open. When you are done, send your full result with the ask back line from your brief.
```

## Dispatch

Recruits, roles, floors and routines need Maestro Mode. Only the Maestro terminal can run `maestri recruit`, `maestri dismiss`, `maestri preset list`, `maestri role`, `maestri floor create`, `maestri floor list` and `maestri routine`. Any terminal can run `maestri list`, `maestri ask`, `maestri check`, `maestri note`, `maestri portal` and `maestri floor status`. Check once per chat: run `maestri preset list`.

### Inside the Maestro

Every subagent is a recruit. Do not use the `Agent` tool. A recruit lives through four steps.

1. **Recruit.** Run `maestri list` first. Then `maestri recruit "<codename>" --role "<pstack role>"` with the agent its sheet value names:
   - A Claude alias: `--command "claude --model <alias> --effort <effort>"`. Leave out `--effort` when the value names none.
   - A preset: `--preset "<name>"`.
   - `inherit-parent`: neither flag, so the recruit is a copy of you.

   A builder also gets its own floor (see [Floors](#floors)). Invent a short codename per recruit, and never reuse the role name.
2. **Check it booted.** Run `maestri check "<codename>"` before the first ask. A fresh Claude Code recruit can stop at the folder-trust prompt. Accept it with `maestri ask "<codename>" --raw "\n"`. A fresh Codex recruit can open a "hook needs review" screen. Close it with `--raw "\e"`. When a prompt does not clear, ask the user to click it.
3. **Brief.** `maestri ask "<codename>" "<brief>"`. The brief names the persona file, the checkout or scratch path, and the task. It ends with the ask back line, `maestri ask "<your name>" "<result>"`, so the full result comes back to you. A recruit does not share this chat's context, so the brief inlines what it needs or points at files.
4. **Dismiss.** Once its result is in and you have read it, run `maestri dismiss "<codename>"`. Keep a recruit only while it still holds something: a PR it owns that is not merged or closed, a floor in `review` that waits on the user, a process the next step needs (a dev server, a simulator, a PR watcher), or a fix round that needs its uncommitted changes. Dismiss it once that ends. Dismiss only recruits this run created.

A panel or a fan-out recruits every member first, then briefs them all through one `maestri ask --batch`, run in the background, so they work in parallel. Dismiss each member once the batch returns and you have read its result.

### Outside the Maestro

If `maestri preset list` fails with "This terminal is not the Maestro", this chat has no recruits. Say so once, and use these fallbacks:

- Every subagent runs as a local subagent: the `Agent` tool with `run_in_background: true`, `subagent_type` set to the persona (`maestri-pstack:poteto-agent` for a builder, none for the other roles unless the skill names one), `model` set to the alias, and `effort` set to the alias's `@effort` when the sheet names one. Leave out `model` for `inherit-parent`. A builder gets `isolation: "worktree"` in place of a floor. Put the role's rule in the brief: "Do not edit files." for a reviewer, a researcher or a verifier.
- A panel member on a preset follows the panel fallback above.
- A fixed-cadence routine becomes Claude Code's `/loop <interval>`.
- Work that must outlive the turn goes to the user, who can run it from the Maestro terminal.
- Portals still work. A verifier drives web and mobile through `maestri portal`, and closes what it opened.

The orchestrate, autopilot-full and multi-phase-plan playbooks have no fallback. Their programs run for days, recover from restarts through floors, and arm their audit as a routine, and a local subagent or `/loop` dies with the chat. Outside the Maestro they stop and ask the user to start them from the Maestro terminal.

## Floors

A builder works on its own git floor: `maestri floor create "<task>" --branch <branch>`, then `maestri recruit ... --floor "<task>"`. To start from an existing branch, add `--existing-branch`, or `--copy` when the ground has that branch checked out. Never pass `--no-git` for a builder. It shares the ground checkout, so parallel builders overwrite each other.

A floor belongs to this Maestri workspace, so it is a worktree of the workspace's directory. When that directory is not the repository the builder changes, do not create a floor. Run `git worktree add <path> <branch>` in the repository, and recruit with `--dir <path>`.

A builder that edits the caller's own checkout while the caller waits, such as comment-sicko on the current diff, gets no floor. Recruit it with `--dir` on that checkout.

A reviewer, a researcher and a verifier need no floor of their own. A verifier that must run the PR head gets a floor on it: `maestri floor create --pull-request <number>`.

## Fresh agents and reuse

Upstream says to give new work to a fresh subagent. Maestri says to reuse a teammate before recruiting a new one. Both rules hold:

- A fresh agent for a role whose recruit is still alive is `maestri recruit "<codename>" --replace "<codename>" --role "<pstack role>"` with the same agent flags. The process restarts with a clean context. The terminal, its connections and its floor stay. Use it for the next round of a PR owner, not to turn a runner into a judge: a recruit that changes function gets the new role in the same `--replace`.
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
| `readonly` / Ask mode | The `pstack-reviewer`, `pstack-researcher` or `pstack-verifier` role. |
| `control-ui`, `control-cli` | A `pstack-verifier` recruit. It follows the project's verification skill for the steps and drives the surface through Maestri: a portal for web, a device portal for mobile, its own terminal for CLIs and TUIs. |
| `/visualize`, canvases | `maestri note create --name "<name>"` with markdown. |
| `.cursor/rules/pstack-models.mdc` | The model sheet. |
| `/create-skill` | Claude Code's skill-authoring skill. |
| `/add-plugin pstack` | The install steps in the README. |

## Floor status

A recruit that works on a floor keeps that floor's status current with `maestri floor status`. It posts when it starts, at a real milestone, with `--state blocked` when it needs the user, and with `--state review` when the work is ready. The coordinator reads `maestri floor list` before it checks each recruit.

## Safety

A run closes what it created. It dismisses its own recruits per [Dispatch](#inside-the-maestro), and a verifier closes its own portals. It never dismisses a teammate, or closes a portal, that it did not create.

Only run these after the user explicitly asks or confirms: `maestri floor land`, `maestri floor delete`, `maestri routine delete`, `maestri note delete`, and `maestri dismiss` or `maestri portal close` on anything this run did not create. A floor in `review` is ready for the user to decide. It is not a signal to land it. GitHub merges in the shipping playbooks follow Lauren's rules unchanged.
