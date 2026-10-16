---
name: swarm
description: "Fan out N parallel workers, drain them, and return one report. Use for /swarm, 'swarm this', or parallel coverage, races, gauntlets, and exploration."
disable-model-invocation: true
---

# Swarm

`<plugin root>` is the directory two levels above this skill's base directory. It holds `CONTEXT.md` and `models.json`.

Recruits, floors, and routines need this terminal to be the Maestro. Without it, use the fallbacks in `<plugin root>/CONTEXT.md`.

## Start

Open a todolist with one entry per phase before launching anything.

1. Frame
2. Fan out
3. Aggregate
4. Report

## Phase A: Frame

1. State the done predicate and the artifact or report the swarm must return.
2. Choose the shape. Partition into slices, race N workers on identical briefs, or mix both. For a race or mixed shape, declare `first pass`, `rank all`, or `best-of` before spawning.
4. Pick the worker model from the `swarm workers` line in the model sheet (`~/.config/maestri-pstack/models.md`). If the sheet or that line is missing, use `sonnet`. For `inherit-parent`, omit `model` so the workers run on the parent model. If the `Agent` tool rejects an alias, use the default and say so. A `preset:` value runs its workers as recruits. For a model race, name each arm's model up front. Pick each subagent's reasoning level for the job, per the Subagents section of the **poteto-mode** skill.
5. Give each worker its own writable output when it writes. When workers verify or measure commits, each brief names the exact SHAs. A measurement brief also names the method (sample count, what one sample is, order). The worker records both in its result.

## Phase B: Fan out

Spawn all N workers at once. Each worker dispatches by the rules in `<plugin root>/CONTEXT.md`. A worker that writes files runs as a recruit on its own floor (`maestri floor create`, then `maestri recruit --floor`). A worker that only reads or measures runs as a background `Agent` call with no `subagent_type` and the step 4 model, left unset for `inherit-parent`. Send all local workers in one message, and all canvas workers through one `maestri ask --batch`. Run `maestri list` before you recruit, and reuse a teammate with `maestri recruit --replace`.

When a worker must start from a non-default branch, create its floor with `maestri floor create "<slice>" --existing-branch --branch <branch>`, or `--copy` when the ground floor has that branch checked out. Outside the Maestro, run `git worktree add <path> <branch>` yourself and name that path in the worker's brief.

Every brief stands alone. Include the goal, scope, exact slice or race arm, how to verify, and what to report. Reports use `PASS`, `ISSUES`, or `BLOCKED` with evidence. A worker that can prove a defect reports `ISSUES` and lists every issue it can prove, not only the first.

If a worker drops out, proceed with N-1 and note it.

## Phase C: Aggregate

Read the terminal results. Drop a result that does not record the SHAs and method its brief names, and respawn that worker once. After a second miss, record a gap. A gap does not count as a pass. For coverage, every required slice needs a result. For a race, apply the selection rule declared up front. Use first pass, rank all, or best-of. Do not paste raw worker dumps.

## Phase D: Report

Return one consolidated in-chat report with the table, issue one-liners, gaps or dropouts, and the race rule when used.
