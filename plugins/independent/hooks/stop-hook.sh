#!/bin/bash
# Stop hook for Independent plugin
# Checks if all tasks are complete before allowing exit

TASKLIST_FILE="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/TASKLIST.md"

# If no tasklist, allow exit
if [[ ! -f "$TASKLIST_FILE" ]]; then
    printf '{"decision": "approve", "reason": "No TASKLIST.md found, allowing exit"}\n'
    exit 0
fi

# Count tasks (case-insensitive for completed tasks)
TOTAL_TASKS=$(grep -cE '^\s*- \[.\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
COMPLETED_TASKS=$(grep -ciE '^\s*- \[x\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
PENDING_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))

# If all tasks complete, allow exit
if [[ $PENDING_TASKS -eq 0 ]]; then
    printf '{"decision": "approve", "reason": "All %d tasks completed"}\n' "$TOTAL_TASKS"
    exit 0
fi

# Tasks remaining - block exit and prompt to continue
# Get pending tasks and escape for JSON (replace quotes, convert newlines)
PENDING_LIST=$(grep -E '^\s*- \[ \]' "$TASKLIST_FILE" 2>/dev/null | head -5 | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g' | tr '\n' '|' | sed 's/|$//' | sed 's/|/\\n/g')

printf '{"decision": "block", "reason": "Tasks incomplete - %d of %d tasks remaining", "pending_tasks": "%s"}\n' \
    "$PENDING_TASKS" "$TOTAL_TASKS" "$PENDING_LIST"

exit 2
