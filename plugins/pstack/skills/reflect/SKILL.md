---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

`<plugin root>` is the directory two levels above this skill's base directory. It holds `CONTEXT.md` and `models.json`.

Recruits, floors, and routines need this terminal to be the Maestro. Without it, use the fallbacks in `<plugin root>/CONTEXT.md`.

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript in this project's Claude Code transcript directory, `~/.claude/projects/<project>/`, where `<project>` is the working directory's absolute path with every character other than a letter or digit replaced by `-`. Do not glob across `~/.claude/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
ls -t ~/.claude/projects/<project>/*.jsonl ~/.claude/projects/<project>/*/subagents/*.jsonl 2>/dev/null | head -10
```

That covers the session (`<session-id>.jsonl`) and subagent (`<session-id>/subagents/<child>.jsonl`) layouts. For each candidate, read its first line with `"type":"user"`. Take the file whose user message contains the conversation's opening user prompt. If none matches, pass a tight digest of the session instead. For a live Maestri teammate with no transcript in this project, read its screen with `maestri check "<codename>"`.

## 2. Spawn three reviewers in parallel

Three `pstack-reviewer` recruits, dispatched by `<plugin root>/CONTEXT.md` and briefed through one `maestri ask --batch`, with the transcript path in each brief. Dismiss each once its output is in. Outside the Maestro, one message with three background `Agent` calls with no `subagent_type`, so they keep this session's MCP tools. Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, so do not restrict their tools. Each template already tells the reviewer not to modify files.

Each reviewer and the synthesizer name a role line in the model sheet (`~/.config/maestri-pstack/models.md`) and a default. Run each on that line's value, or on the default if the sheet or the line is missing. If the recruit or the `Agent` tool rejects an alias, use the default and say so. Pick each subagent's reasoning level for the job, per the Subagents section of the **poteto-mode** skill.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `opus` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `opus` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `opus` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in their final message.

## 3. Synthesize

One `pstack-reviewer` recruit on the `reflect judgment, divergent, synthesizer` line (default `opus`), dismissed once its list is in. Outside the Maestro, one background `Agent` call with no `subagent_type`. It spot-verifies citations through MCP, so do not restrict its tools. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to Claude Code's `skill-creator` skill and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-optimization loop.
- `new skill via skill-creator: <kebab-name>`: hand creation to `skill-creator`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
