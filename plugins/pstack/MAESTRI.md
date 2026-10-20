# Maestri execution reference

Read this file once before running any skill in this package. The copied `source/skills/` tree is the Cursor pstack source. Keep its task logic and engineering standards. Interpret its Cursor tools and model slugs through the rules here. If an upstream step needs a capability Maestri lacks, state the specific missing capability and continue only when the remaining workflow still proves the requested result.

## Coordinator and source

The coordinator runs in a Maestri terminal with Maestro enabled. Run `maestri list` first and confirm `maestro: true` under `You`. Use `maestri preset list` and `maestri role list` before recruiting. If Maestro is off, explain which step needs it and ask the user to enable Maestro on this terminal. Do not silently switch to an in-chat subagent because that would hide the work from the canvas.

`<pstack>` in upstream text means this package's `source/` directory. Read another pstack skill at `<pstack>/skills/<name>/SKILL.md`, the original guides under `<pstack>/docs/`, and agent personas under `<pstack>/agents/`. The upstream README is `<pstack>/README.md`; this package's README describes the Maestri adapter. Resolve relative references from the source file. Other installed skills are invoked through the current host's skill mechanism when available. If a named external skill is unavailable, follow its concrete steps from the upstream source when those steps are present; do not invent its behavior.

The source tree is reference material, not a set of separately installed commands. Read `source/setup/SKILL.md` instead of the Cursor `setup-pstack` skill. When `poteto-help` names a Cursor command or install path, use this package's `SKILL.md`, `MAESTRI.md`, and README for actual Maestri instructions. The copied `source/automations/` files document Cursor automations; they do not create a Maestri routine or webhook.

## Presets and model families

The user's optional model sheet is `~/.config/maestri-pstack/presets.json`. `source/setup/SKILL.md` creates it. The `roles` object maps each upstream role label to a Maestri preset name or `inherit-parent`. Panel roles contain an array; each entry gets one recruit. The `families` object maps a preset name to its actual model family, such as `claude`, `openai`, `grok`, `kimi`, or `glm`.

Before a multi-model run, check each selected preset with `maestri preset show "<name>"` as well as `maestri preset list`. The preset's account and command determine the actual agent. A successful JSON shape validation does not prove the account can answer; run a small read-only brief before claiming a new provider works. Do not infer the recruit's active CLI profile from the canvas account label when its command sets a separate config directory.

If the file is missing, a single-worker role may use `inherit-parent`. If a role is missing from an existing file, repair the incomplete configuration through `source/setup/SKILL.md` before dispatch; the validator requires all role labels. A panel needs configured seats and families. If only one family is available, state that limitation and use two seats only when the workflow needs two independent judgments. For `interrogate`, verify that the reviewers include different actual model families; two preset names alone do not prove diversity. `inherit-parent` recruits a copy of this terminal; a preset value recruits with `--preset "<name>"`. A preset controls its own model, account, and reasoning settings. Never send `/model` to a recruit or rewrite its preset during a run.

The following upstream labels are configuration keys: `feature, refactoring`, `bug-fix`, `perf-issue`, `hillclimb`, `hardest tasks`, `judgment and prose`, `how explorer`, `how explainer`, `why investigators`, `why synthesizer`, `reflect tooling`, `reflect judgment, divergent, synthesizer`, `swarm workers`, `arena runners`, `arena cross-judge pool`, `architect runners`, and `interrogate reviewers`. The `arena cross-judge pool` is a choice pool, not a fan-out: choose a family different from the parent's when possible.

Upstream Cursor model slugs, effort tokens, `auto`, and its `pstack-models.mdc` rule do not select a Maestri agent. Use the role value above. If a skill names a model directly, look up the role that its Models section assigns and use that role's preset. If a configured preset is unavailable, stop that dispatch and repair the configuration through `source/setup/SKILL.md`. Never silently substitute another agent or claim a cross-family panel that did not run.

## Dispatch

Classify the work before recruiting:

| Work | Maestri role | Repository edits |
|---|---|---|
| Code, prototype, candidate, fix round | `maestri-pstack-builder` | Yes, in its assigned checkout |
| Independent judgment or review | `maestri-pstack-reviewer` | No |
| Read-only investigation or explanation | `maestri-pstack-researcher` | No |
| Live verification | `maestri-pstack-verifier` | No |

Create missing roles from the role prompts below before first use. Run `maestri list` before each recruitment. Reuse a connected teammate whose role and current work fit; do not create a duplicate. For an upstream request for a fresh agent after a builder's round ends, run `maestri recruit "<new name>" --preset "<preset>" --replace "<old name>"`. The replacement keeps the old node's role, floor, connections, and Maestri chat history, but starts with fresh provider context. Do not pass `--role` or `--floor` with `--replace`. Give the replacement the checkout path, prior result, and next-round scope in a new brief. Do not replace an agent that still owns a process or uncommitted work.

For a builder that writes files, create a git floor first with `maestri floor create "<task>" --branch <branch>`, then recruit it on that floor. Give separate builders separate floors. A builder explicitly editing the coordinator's checkout for a serial step may use `--dir` instead. Reviewers and researchers read the named checkout without a new floor. A verifier may need a floor at the PR head to run the right build.

Recruit with `maestri recruit "<codename>" --role "<role>" --preset "<preset>"` or omit `--preset` for `inherit-parent`. Add `--floor` or `--dir` when needed. Pick a short distinct codename, not the role name. Run `maestri check "<codename>"` to ensure it booted and clear any interactive prompt before briefing it.

Send a brief with `maestri ask "<codename>" "<brief>"`. The brief states the task, absolute checkout path, relevant skill and persona paths, read-only or edit authority, expected evidence, and the ask-back line `maestri ask "<coordinator name>" "<full result>"`. Take the coordinator's exact name from `maestri list`. For parallel independent work, recruit all seats first and use `maestri ask --batch` with one prompt per seat. If an ask times out, use `maestri check`; do not resend the task.

Before `interrogate` or another diff review, resolve the target's absolute checkout with `maestri floor list` and run diff commands in that directory. Record the fixed base commit or branch, the committed diff against it, `git diff` for unstaged changes, and `git diff --cached` for staged changes. A Ground checkout on `main` can produce an empty `git diff main...HEAD` while a floor or working tree holds the change. Confirm the combined scope is the intended review target, then put its checkout path, base, and diff commands in every reviewer's brief. An empty committed diff alone is not proof that there is nothing to review.

Review each result and the actual diff yourself. Keep a recruit while it owns a process, uncommitted work, or a floor awaiting review. Dismiss recruits created by this run when their work is incorporated. Do not dismiss a pre-existing teammate. Do not land or delete a floor without the user's explicit request.

## Cursor operation map

| Cursor instruction | Maestri action |
|---|---|
| `Task`, `subagent_type`, `readonly`, background/cloud agent | Recruit through the procedure above. The role and brief set authority; a git floor isolates writers. |
| `AskQuestion` | Ask the user through the host's question tool, or in chat when no such tool exists. |
| Open a todo list | Use the host's task list if available; otherwise keep and update a compact list in the conversation. |
| `/loop` on a fixed interval or an automation | Use a Maestri routine when Maestro is enabled and the task needs a recurring command. Inspect `maestri routine --help` before creating one. |
| `/loop` until a condition holds | Recheck the condition in the current run, with a bounded cadence and explicit stop condition. |
| Cursor browser or `control-ui` | Give a verifier a connected Maestri portal. Use `maestri portal snapshot`, `click`, `fill`, `logs`, and `screenshot` as the surface requires. |
| Cursor cloud worktree | Use a Maestri git floor. |
| Cursor canvas or visualization | Use a connected Maestri note when a shared visual status helps. |
| `agent-transcripts` | Use the current host's transcript only when its path is known for this session. `maestri check` shows a live recruit, but is not a historical transcript. |
| Built-in PR tool | Use the project's configured forge CLI, such as `gh`, after checking the repository's delivery conventions. Run branch-sensitive commands from the target floor's checkout, not the Maestro's Ground checkout. |

Do not equate a portal screenshot with browser console evidence. Start portal logs before reproducing a behavior that needs console inspection. For non-browser verification, the verifier uses the project's real CLI or test surface.

When the upstream Opening a PR playbook applies, resolve the floor's absolute checkout path with `maestri floor list`. Run `git branch --show-current`, status, push, and the forge's PR create command with that directory as the working directory; confirm the branch matches the floor before publishing. The Ground terminal can coordinate the command, but its default working directory is not the floor. Do not open a PR from `main` merely because the Maestro is on Ground.

Keep upstream `Cursor` product instructions only when that product is itself the subject of the task. A step requiring Cursor Bugbot, a Cursor automation webhook, or a Cursor-only dashboard has no Maestri equivalent. Mark that step unavailable and evaluate whether the workflow's completion criterion still holds.

Project-local skills created by an upstream playbook must go into a directory that the active host actually loads. For Codex, use the project's `.agents/skills/`; for Claude Code, use `.claude/skills/` or this plugin's packaging. Check discovery in the intended host before declaring the skill complete. Do not write a new `.cursor/skills/` tree for a Maestri-only project. Transcript-dependent skills (`recall`, `reflect`, `show-me-your-work`, `automate-me`) may read only an identified transcript for the current session. If the host cannot identify it, say which step is blocked and use current-session evidence only; do not glob unrelated projects or claim a full transcript audit.

## Partituras: execução dos playbooks

Uma partitura descreve quem entra, em que ordem e qual evidência encerra cada etapa. O Maestro escolhe o playbook pela tarefa e mantém o estado no canvas; o playbook continua sendo a fonte das etapas técnicas. Não crie floors para uma leitura simples. Crie um floor por linha de implementação independente, usando uma branch por floor. O Maestro integra os resultados após ler diffs e evidências; nunca faça o merge apenas porque um agente declarou sucesso.

| Playbook | Sequência no canvas | Floor e evidência |
|---|---|---|
| `investigation` / `how` / `why` | Pesquisador → Maestro sintetiza | Checkout nomeado; caminhos, fontes e limites da conclusão. |
| `bug-fix` | Pesquisador (se a causa não está clara) → Builder → Verifier → Reviewer → Maestro | Um floor do builder; reprodução inicial, teste da correção e diff revisto. |
| `feature` / `refactoring` | Maestro define escopo → Builder → Verifier → Reviewer → Maestro | Um floor por implementação independente; testes do projeto e comportamento observado. |
| `arena` / `architect` | Builders independentes → Reviewers cruzados → Maestro escolhe | Floors distintos por candidato; comparação pelos mesmos critérios antes de integrar. |
| `swarm` | Builders para tarefas separáveis → Maestro integra → Verifier | Floors distintos; interfaces combinadas antes do trabalho e teste integrado ao final. |
| `interrogate` / `reflect` | Reviewers de famílias diferentes → Maestro julga achados | Checkout somente leitura; cada achado com arquivo/linha ou evidência observável. |

O modelo de cada assento vem de `presets.json`. A role define autoridade, não a família do modelo. Com Claude como Maestro, o terminal Claude planeja, recruta, acompanha e integra; o mesmo esquema funciona com Codex como Maestro. Anote em uma nota conectada a partitura ativa, nomes dos floors, assentos, bloqueios e links de evidência quando o fluxo tiver mais de uma etapa.

Para verificação web, conecte um portal ao floor cujo bundle será testado. Confirme que o servidor contém o código daquele floor; depois de navegar, rode `maestri portal logs-start "<nome do portal>"` antes da reprodução quando console importa. Obtenha `maestri portal snapshot "<nome do portal>"`, ações, `maestri portal logs "<nome do portal>"` e screenshot como evidência. Todo verbo de portal recebe o nome exato exibido em `maestri list`. Para iOS ou Android, rode `maestri portal devices`, escolha um simulador livre, crie o portal com `--simulator`, confira `portal info`, construa/instale o app naquele dispositivo e use `snapshot`, `launch` e ações em pixels. Um portal ou simulador ocupado não deve ser reutilizado por outro verifier. Não feche portais sem pedido explícito do usuário.


## Role prompts

`source/setup/SKILL.md` creates these Maestri roles as global roles. The role is a stable boundary; task-specific files and instructions go in the brief.

- `maestri-pstack-builder`: You implement the task in the checkout named in your brief. Read the named skill and persona files first. Run `maestri list` before collaborating. Keep your floor status current. Follow the project's instructions and required validation. Report your changes, checks, and remaining risks through the ask-back line. Do not land a floor or dismiss a teammate.
- `maestri-pstack-reviewer`: You independently review the named work. Read the named skill and persona files first. Run `maestri list` before collaborating. Do not edit the repository. Report findings with file and line evidence through the ask-back line.
- `maestri-pstack-researcher`: You investigate the named question. Read the named skill and persona files first. Run `maestri list` before collaborating. Do not edit the repository. Return concise findings with source paths and evidence through the ask-back line.
- `maestri-pstack-verifier`: You verify the named behavior on the real surface. Read the named skill and persona files first. Run `maestri list` before collaborating. Use a Maestri portal for web or device checks and the real CLI for terminal checks. Do not edit the repository. Report commands, outputs, screenshots, or logs through the ask-back line.
