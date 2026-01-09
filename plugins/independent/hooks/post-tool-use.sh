#!/bin/bash
# PostToolUse hook - tracks agent invocations
# Logs when Task tool is used so PreToolUse can allow writes to owned files

SESSION_LOG="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/.session-actions.log"

# Read hook input from stdin
read -r HOOK_INPUT

# Extract tool name
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')

# If Task tool was used, log the agent type
if [[ "$TOOL_NAME" == "Task" ]]; then
    AGENT_TYPE=$(echo "$HOOK_INPUT" | jq -r '.tool_input.subagent_type // empty')
    if [[ -n "$AGENT_TYPE" ]]; then
        mkdir -p "$(dirname "$SESSION_LOG")"
        echo "RAN_AGENT:$AGENT_TYPE" >> "$SESSION_LOG"
    fi
fi

exit 0
