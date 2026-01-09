#!/bin/bash
# SubagentStart hook - injects pending task context into subagents

TASKLIST_FILE="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/TASKLIST.md"

if [[ -f "$TASKLIST_FILE" ]]; then
    # Count tasks
    TOTAL_TASKS=$(grep -cE '^\s*- \[.\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
    COMPLETED_TASKS=$(grep -ciE '^\s*- \[x\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
    PENDING_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))

    # Extract pending tasks (unchecked items)
    PENDING_LIST=$(grep -E '^\s*- \[ \]' "$TASKLIST_FILE" 2>/dev/null | sed 's/^\s*- \[ \] //' | head -10)

    # Format as context message
    CONTEXT="[Independent Loop Context] Progress: ${COMPLETED_TASKS}/${TOTAL_TASKS} tasks completed. Pending tasks (${PENDING_TASKS}):
${PENDING_LIST}"

    # Escape for JSON
    CONTEXT_ESCAPED=$(echo "$CONTEXT" | jq -Rs '.')

    printf '{"status": "ok", "context": %s}\n' "$CONTEXT_ESCAPED"
else
    printf '{"status": "ok"}\n'
fi

exit 0
