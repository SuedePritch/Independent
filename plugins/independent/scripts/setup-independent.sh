#!/bin/bash
# Setup script for Independent task loop
# Initializes the task tracking environment and shows available specialists

TASKLIST_FILE="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/TASKLIST.md"
AGENTS_DIR="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/agents"
SKILLS_DIR="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/skills"

# Check if TASKLIST.md exists
if [[ ! -f "$TASKLIST_FILE" ]]; then
    echo "Error: TASKLIST.md not found in .claude folder"
    echo "Please create .claude/TASKLIST.md with tasks in the format:"
    echo "  - [ ] Task description"
    exit 1
fi

# Count tasks (case-insensitive for completed tasks)
TOTAL_TASKS=$(grep -cE '^\s*- \[.\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
COMPLETED_TASKS=$(grep -ciE '^\s*- \[x\]' "$TASKLIST_FILE" 2>/dev/null || echo "0")
PENDING_TASKS=$((TOTAL_TASKS - COMPLETED_TASKS))

echo "=== Independent Task Loop Initialized ==="
echo "Tasklist: $TASKLIST_FILE"
echo "Total tasks: $TOTAL_TASKS"
echo "Completed: $COMPLETED_TASKS"
echo "Pending: $PENDING_TASKS"
echo ""

if [[ $PENDING_TASKS -eq 0 ]]; then
    echo "All tasks are already complete!"
else
    echo "Pending tasks:"
    grep -E '^\s*- \[ \]' "$TASKLIST_FILE" | head -10
    echo ""
    echo "Work through these tasks. Mark each complete by changing '- [ ]' to '- [x]'"
fi

# --- Show Available Specialists ---
# Function to extract owns patterns from frontmatter
extract_owns() {
    local md_file="$1"
    awk '/^---$/{if(++c==1)next; if(c==2)exit} c==1' "$md_file" 2>/dev/null | \
        grep -A100 '^owns:' | \
        grep '^\s*-' | \
        sed 's/^\s*-\s*["'"'"']\?\([^"'"'"']*\)["'"'"']\?\s*$/\1/' | \
        tr '\n' ', ' | sed 's/, $//'
}

# Collect specialists with owns patterns
SPECIALISTS=""
for dir in "$AGENTS_DIR" "$SKILLS_DIR"; do
    [[ -d "$dir" ]] || continue

    for md_file in "$dir"/*.md; do
        [[ -f "$md_file" ]] || continue

        name=$(basename "$md_file" .md)
        owns=$(extract_owns "$md_file")

        if [[ -n "$owns" ]]; then
            SPECIALISTS="${SPECIALISTS}  - ${name} (owns: ${owns})\n"
        fi
    done
done

if [[ -n "$SPECIALISTS" ]]; then
    echo ""
    echo "=== Available Specialists ==="
    echo "These agents/skills own specific file patterns."
    echo "Delegate to them instead of writing those files directly:"
    echo ""
    printf "$SPECIALISTS"
    echo ""
    echo "Use the Task tool to invoke these specialists for files they own."
fi

exit 0
