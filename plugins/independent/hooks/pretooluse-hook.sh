#!/bin/bash
# PreToolUse hook for Independent plugin
# 1. Enforces agent ownership - blocks writes to files owned by agents until delegated
# 2. Monitors task progress before each tool use

SESSION_LOG="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/.session-actions.log"
AGENTS_DIR="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/agents"
SKILLS_DIR="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/skills"

# Read hook input from stdin
read -r HOOK_INPUT

# Extract tool name and file path
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // empty')

# --- Ownership Enforcement ---
# Only check for Write and Edit tools with a file path
if [[ "$TOOL_NAME" == "Write" || "$TOOL_NAME" == "Edit" ]] && [[ -n "$FILE_PATH" ]]; then

    # Function to check if a file matches a glob pattern
    match_pattern() {
        local file="$1"
        local pattern="$2"

        # Handle ** patterns (match any path)
        if [[ "$pattern" == *"**"* ]]; then
            # Convert ** to regex
            local regex="${pattern//\*\*/.*}"
            regex="${regex//\*/[^/]*}"
            regex="^${regex}$"
            [[ "$file" =~ $regex ]]
        else
            # Simple glob match using bash pattern matching
            local filename=$(basename "$file")
            local glob_pattern="${pattern//\*/.*}"
            glob_pattern="^${glob_pattern}$"
            [[ "$filename" =~ $glob_pattern ]]
        fi
    }

    # Function to extract owns patterns from frontmatter
    extract_owns() {
        local md_file="$1"
        # Extract YAML frontmatter and parse owns array
        awk '/^---$/{if(++c==1)next; if(c==2)exit} c==1' "$md_file" 2>/dev/null | \
            grep -A100 '^owns:' | \
            grep '^\s*-' | \
            sed 's/^\s*-\s*["'"'"']\?\([^"'"'"']*\)["'"'"']\?\s*$/\1/'
    }

    # Check all agents and skills for ownership
    for dir in "$AGENTS_DIR" "$SKILLS_DIR"; do
        [[ -d "$dir" ]] || continue

        for md_file in "$dir"/*.md; do
            [[ -f "$md_file" ]] || continue

            # Get agent/skill name from filename
            agent_name=$(basename "$md_file" .md)

            # Extract owns patterns
            while IFS= read -r pattern; do
                [[ -z "$pattern" ]] && continue

                if match_pattern "$FILE_PATH" "$pattern"; then
                    # Found a matching pattern - check if agent was run
                    if [[ -f "$SESSION_LOG" ]] && grep -q "RAN_AGENT:$agent_name" "$SESSION_LOG"; then
                        # Agent was already invoked, allow the write
                        break 2
                    else
                        # Agent not invoked - block and suggest delegation
                        printf '{"decision": "block", "reason": "File '"'"'%s'"'"' matches pattern '"'"'%s'"'"' owned by '"'"'%s'"'"' agent. Delegate to this agent instead of writing directly."}\n' \
                            "$FILE_PATH" "$pattern" "$agent_name"
                        exit 0
                    fi
                fi
            done < <(extract_owns "$md_file")
        done
    done
fi

# --- Task Progress Monitoring (existing behavior) ---
TASKLIST_FILE="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/TASKLIST.md"

if [[ -f "$TASKLIST_FILE" ]]; then
    # Count tasks (case-insensitive for completed tasks)
    TOTAL_TASKS=$(grep -cE '^\s*- \[.\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
    COMPLETED_TASKS=$(grep -ciE '^\s*- \[x\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
    PENDING_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))

    # Output status as JSON for Claude to see
    printf '{"status": "ok", "tasks_total": %d, "tasks_completed": %d, "tasks_pending": %d}\n' \
        "$TOTAL_TASKS" "$COMPLETED_TASKS" "$PENDING_TASKS"
else
    printf '{"status": "ok", "message": "No TASKLIST.md found"}\n'
fi

exit 0
