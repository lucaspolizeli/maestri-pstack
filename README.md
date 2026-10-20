# maestri-pstack

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), run by a Claude or Codex Maestro in [Maestri](https://maestri.app). The copied pstack source is pinned to Cursor's `ddf824aff1e55ba14bd666b30bce3fc69962abe6` commit (2026-10-19); [MAESTRI.md](plugins/pstack/MAESTRI.md) describes the Maestri adaptation.

## Install

For Codex, run `scripts/install.sh`. It installs one discoverable skill at `~/.agents/skills/maestri-pstack` and stores the upstream source at `~/.local/share/maestri-pstack`. Run it again after updating the repository. Previous copies are backed up outside the skill search directory.

For Claude Code, run `claude plugin install maestri-pstack --marketplace . --scope user` from this repository, or load `plugins/pstack` as a local plugin. After publishing the marketplace, `/plugin install maestri-pstack --marketplace lucaspolizeli/maestri-pstack` works in Claude Code. The plugin exposes `/maestri-pstack:run` and `/maestri-pstack:setup`.

## Use

In a Maestri terminal with Maestro enabled, invoke `$maestri-pstack` in Codex or `/maestri-pstack:run` in Claude. A named skill can follow the invocation, such as `interrogate this diff`. The default entry selects a pstack playbook through `poteto-mode`.

Run setup before a multi-model panel. It maps pstack seats to presets from `maestri preset list` and records each preset's model family. Panels can mix Claude, Codex, Grok, Kimi, GLM, and other runnable Maestri agents when matching presets exist. Builders work in isolated git floors; reviewers and researchers inspect a named checkout; verifiers use portals or real CLI surfaces.

## Verify

Run `scripts/check.sh`. It checks configuration validation, installer behavior, shell syntax, upstream Bun tests, and type checking. Run `claude plugin validate plugins/pstack` to validate the Claude package.

## Source and license

Upstream skills and agent text live under `plugins/pstack/source/`, copied from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), MIT licensed by Lauren Tan. See [the upstream license](plugins/pstack/LICENSE). The Maestri adapter is maintained here.
