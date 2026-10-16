#!/bin/sh
# Injects the maestri-pstack mandate into sessions that run in a Maestri terminal.
# Outside Maestri it prints nothing.
[ -n "${MAESTRI_TERMINAL_ID:-}" ] || exit 0
. "${CLAUDE_PLUGIN_ROOT}/hooks/maestro.sh"

if is_maestro; then
  dispatch="This terminal is the Maestro. Every subagent a maestri-pstack skill spawns is a Maestri recruit with a pstack role, dismissed once its result is in. Do not use the Agent tool for them. A hook denies it."
else
  dispatch="This terminal is not the Maestro, so it cannot recruit. maestri-pstack skills use the local fallbacks in CONTEXT.md. If the user turns Maestro on mid-session, recruits apply from then on."
fi

cat <<EOF
<EXTREMELY_IMPORTANT>
You have maestri-pstack, and this session runs in a Maestri terminal.

Invoke the \`maestri-pstack:poteto-mode\` skill and follow its instructions when a task meets any of these:

- it touches more than one file, or changes a signature other files call
- it involves a design or architecture choice
- it is a bug whose cause is not yet known, or a performance issue

It routes to the right skill from there. For smaller tasks, such as a contained change to one file with an obvious test, a question, or a one-line edit, work directly and verify on the real artifact.

When the intent is already specific, enter that skill directly: \`maestri-pstack:tdd\`, \`maestri-pstack:architect\`, \`maestri-pstack:how\`, \`maestri-pstack:why\`, \`maestri-pstack:arena\`, \`maestri-pstack:interrogate\`.

${dispatch} Before the first dispatch, read ${CLAUDE_PLUGIN_ROOT}/CONTEXT.md.

User instructions (CLAUDE.md, AGENTS.md, direct requests) take precedence.
</EXTREMELY_IMPORTANT>
EOF
