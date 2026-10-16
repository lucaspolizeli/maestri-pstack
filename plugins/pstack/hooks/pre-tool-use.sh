#!/bin/sh
# Denies a maestri-pstack subagent on the Agent tool when this terminal is the Maestro,
# so the skill recruits it instead. Every other call gets no output and takes the
# normal permission flow, and so does any call when a check cannot run.
[ -n "${MAESTRI_TERMINAL_ID:-}" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
type=$(printf '%s' "$input" | jq -r '.tool_input.subagent_type // ""' 2>/dev/null) || exit 0
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""' 2>/dev/null) || exit 0

# A maestri-pstack persona is always ours. A general-purpose spawn is ours once a
# maestri-pstack skill ran in this session, through the Skill tool or a slash command.
case "$type" in
  maestri-pstack:*) ;;
  "" | general-purpose)
    [ -f "$transcript" ] || exit 0
    grep -q -F -e '"skill":"maestri-pstack:' -e '<command-name>/maestri-pstack:' "$transcript" || exit 0
    ;;
  *) exit 0 ;;
esac

. "${CLAUDE_PLUGIN_ROOT}/hooks/maestro.sh"
is_maestro || exit 0

jq -n --arg reason "maestri-pstack: this terminal is the Maestro, so this subagent runs as a Maestri recruit, not an Agent call. Recruit it with the pstack role of its function (pstack-builder, pstack-reviewer, pstack-researcher or pstack-verifier) and the model its role line names, brief it with maestri ask, and dismiss it once its result is in. The rules are in ${CLAUDE_PLUGIN_ROOT}/CONTEXT.md, under Dispatch." \
  '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
