# maestri-pstack

pstack for [Maestri](https://maestri.app). It is Lauren Tan's (poteto's) [pstack](https://github.com/cursor/plugins/tree/main/pstack), with its Cursor mechanics rewritten for Maestri on Claude Code.

The skill text is Lauren's. Only what names a Cursor mechanism changes. [CONTEXT.md](plugins/pstack/CONTEXT.md) defines the Maestri form:

- A short or read-only subagent runs in the chat, through Claude Code's `Agent` tool.
- A delegate that writes files runs as a Maestri teammate on its own floor (a git worktree).
- A panel that needs another model family, such as Codex, recruits that member through a Maestri preset, so `interrogate`, `arena` and `architect` panels can mix Claude and Codex.
- A fixed-cadence loop runs as a Maestri routine. A loop until a check passes runs as Claude Code's `/loop`.

maestri-pstack works inside a Maestri terminal that runs Claude Code. Routines and floors need Maestro Mode on the coordinating terminal.

## Install

```shell
claude plugin marketplace add /path/to/maestri-pstack
claude plugin install maestri-pstack@maestri-pstack
```

Then run `/maestri-pstack:setup-pstack` once per machine. It writes the model sheet, `~/.config/maestri-pstack/models.md`, and creates the `poteto-agent` role in Maestri. Without a sheet, every role runs on the defaults in [models.json](plugins/pstack/models.json).

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
