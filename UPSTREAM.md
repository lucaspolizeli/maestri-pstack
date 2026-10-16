# Upstream

maestri-pstack is Lauren Tan's (poteto's) pstack, rewritten for Maestri.

| Component | Upstream path | Local path | Commit |
|---|---|---|---|
| pstack | `cursor/plugins` `pstack/` | `plugins/pstack/` | `99743e9c151c8537cbbf1f98bb38f34ef3368453` |
| thermos | `cursor/plugins` `thermos/skills`, `thermos/agents` | `plugins/pstack/skills`, `plugins/pstack/agents` | `99743e9c151c8537cbbf1f98bb38f34ef3368453` |
| cursor-team-kit | `cursor/plugins` `cursor-team-kit/skills` (deslop, fix-ci, fix-merge-conflicts, get-pr-comments, make-pr-easy-to-review, what-did-i-get-done) | `plugins/pstack/skills` | `99743e9c151c8537cbbf1f98bb38f34ef3368453` |

Left out: pstack's `.cursor-plugin/`, `plugin.json`, `README.md`, `docs/`, `assets/`, `automations/` and `skills/make-bot-ui/`; thermos's packaging and README; the cursor-team-kit skills that drive Cursor-only surfaces.
