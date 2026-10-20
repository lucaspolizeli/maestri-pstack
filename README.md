# maestri-pstack

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), run by a Codex Maestro in [Maestri](https://maestri.app). The coordinator uses Maestri recruits, presets, git floors, notes, and portals to carry out pstack workflows. The copied pstack skills are pinned to Cursor's `ddf824aff1e55ba14bd666b30bce3fc69962abe6` commit (2026-10-19); the Maestri behavior lives in [MAESTRI.md](plugins/pstack/MAESTRI.md).

## Install

Run `scripts/install.sh` from this repository. It copies the `maestri-pstack` skill into `~/.agents/skills/maestri-pstack` for Codex. Run it again after updating this repository. The installer moves the previous installed copy to a timestamped backup and prints its path.

## Use

In a Codex terminal with Maestro enabled, invoke `$maestri-pstack` with a task. It starts with pstack's `poteto-mode`. Name a skill after the invocation to use it directly, for example `$maestri-pstack interrogate this diff`.

Run `$maestri-pstack setup` before using a multi-model panel. It maps pstack roles to the presets in `maestri preset list` and records each preset's model family. Panels can then mix Claude, Codex, Grok, Kimi, GLM, or any other agent that Maestri can launch. A model needs a working Maestri preset before pstack can recruit it.

The coordinator and recruits share the local filesystem. A builder that writes files works in a Maestri git floor. Read-only reviewers and researchers work from the checkout named in their brief. The package does not change your Maestri presets.

## Verify

From this repository, run `scripts/check.sh`. It checks skill metadata, configuration validation, shell syntax, and the copied upstream Bun tests and typecheck.

## Source and license

The pstack skill and agent text under `plugins/pstack/skills` and `plugins/pstack/agents` comes from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack), MIT licensed by Lauren Tan. See [the upstream license](plugins/pstack/LICENSE). The Maestri adapter is maintained in this repository.
