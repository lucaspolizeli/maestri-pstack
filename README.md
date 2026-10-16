# maestri-pstack

pstack for [Maestri](https://maestri.app). It is Lauren Tan's (poteto's) [pstack](https://github.com/cursor/plugins/tree/main/pstack), with its Cursor mechanics rewritten for Maestri on Claude Code.

The skill text is Lauren's. Only what names a Cursor mechanism changes. [CONTEXT.md](plugins/pstack/CONTEXT.md) defines the Maestri form:

- Every subagent runs as a Maestri teammate in its own terminal, with a pstack role for its function (builder, reviewer, researcher, verifier). The run closes each one when its work is in.
- A builder that writes files works on its own git floor.
- A verifier drives web pages through a Maestri portal and mobile apps through a device portal.
- A panel that needs another model family, such as Codex, recruits that member through a Maestri preset, so `interrogate`, `arena` and `architect` panels can mix Claude and Codex.
- A fixed-cadence loop runs as a Maestri routine. A loop until a check passes runs as Claude Code's `/loop`.

maestri-pstack works inside a Maestri terminal that runs Claude Code. Recruits, roles, floors and routines need Maestro Mode on the coordinating terminal. Outside it, subagents fall back to Claude Code's `Agent` tool.

In a Maestri terminal, a SessionStart hook routes non-trivial tasks to `poteto-mode`, and on the Maestro a PreToolUse hook denies a maestri-pstack subagent on the `Agent` tool, so it runs as a recruit.

## Install

```shell
claude plugin marketplace add lucaspolizeli/maestri-pstack
claude plugin install maestri-pstack@maestri-pstack
```

Then run `/maestri-pstack:setup-pstack` once per machine. It writes the model sheet, `~/.config/maestri-pstack/models.md`, and creates the four pstack roles in Maestri. Without a sheet, every role runs on the defaults in [models.json](plugins/pstack/models.json).

## Use

```text
/maestri-pstack:poteto-mode fix the search filter resetting when I change pages
```

`poteto-mode` matches the task to a playbook and opens the other skills from there.

## Upstream

[UPSTREAM.md](UPSTREAM.md) pins the upstream commit. `node tools/check-cursorisms.mjs` fails when plugin text still names a Cursor mechanism.

## License

MIT. See [LICENSE](LICENSE). It builds on:

- [pstack](https://github.com/cursor/plugins/tree/main/pstack), MIT, © 2026 Lauren Tan (poteto). See [LICENSE-pstack](LICENSE-pstack).
- [thermos](https://github.com/cursor/plugins/tree/main/thermos) and [cursor-team-kit](https://github.com/cursor/plugins/tree/main/cursor-team-kit), MIT, © 2026 Cursor. See [LICENSE-thermos](LICENSE-thermos) and [LICENSE-cursor-team-kit](LICENSE-cursor-team-kit).
- [t3-pstack](https://github.com/chhoumann/t3-pstack) and [pstack-claude](https://github.com/michael-denyer/pstack-claude) as references for the port's approach.
