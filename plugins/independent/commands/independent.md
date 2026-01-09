---
description: "Start Independent task loop from TASKLIST.md"
argument-hint: "[optional arguments]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-independent.sh:*)"]
---

# Independent Loop Command

Execute the setup script to initialize the Independent task loop:

`! "${CLAUDE_PLUGIN_ROOT}/scripts/setup-independent.sh" $ARGUMENTS`

Work on the tasks in .claude/TASKLIST.md. When you try to exit, the loop will check if all tasks are complete. If not, you'll receive an updated prompt showing the current task status and instructions to continue.

When working on tasks:
- Use the Task tool with appropriate subagent types (Explore, Plan, Bash, etc.) for complex or multi-step work
- Leverage any available skills when relevant to the task
- Break complex tasks into subtasks by adding new items to .claude/TASKLIST.md
- Work autonomously through the list, using your full capabilities

IMPORTANT: Mark tasks as complete by changing `- [ ]` to `- [x]` in .claude/TASKLIST.md when you finish them. Never check off things that arent actually complete. If there is any TODO or incomplete task, do not mark it as complete. The loop monitors this file to detect completion.
