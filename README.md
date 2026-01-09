# Independent Plugin for Claude Code

An autonomous task-driven loop that works through your TASKLIST.md independently. Claude keeps working until all tasks are complete.

## Installation

```bash
# Add the marketplace
/plugin marketplace add SuedePritch/Independent

# Install the plugin
/plugin install independent@jamespritchard-plugins
```

## Usage

### 1. Create a TASKLIST.md

In your project, create `.claude/TASKLIST.md`:

```markdown
- [ ] Refactor the authentication module
- [ ] Add unit tests for user service
- [ ] Update API documentation
- [ ] Fix the bug in checkout flow
```

### 2. Run the Independent Loop

```bash
/independent
```

Claude will:
- Work through each task autonomously
- Use appropriate tools and subagents for complex work
- Mark tasks complete as it finishes them
- Keep going until all tasks are done

### 3. Mark Tasks Complete

Tasks are tracked with checkboxes:
- `- [ ]` = pending
- `- [x]` = complete

Claude marks tasks complete automatically, or you can check them off manually.

## How It Works

The plugin uses Claude Code hooks to enforce task completion:

| Hook | Purpose |
|------|---------|
| **SessionStart** | Clears session log for fresh starts |
| **PreToolUse** | Monitors task progress, enforces agent ownership |
| **PostToolUse** | Tracks agent invocations |
| **Stop** | Blocks exit if tasks remain incomplete |
| **SubagentStart** | Injects pending task context into subagents |

When you try to exit with incomplete tasks, the Stop hook blocks it and shows remaining work.

## Tips

- **Break down complex tasks** — Add subtasks to TASKLIST.md as you discover them
- **Be specific** — "Fix login bug" is better than "Fix bugs"
- **Let it run** — The loop is designed to work autonomously

## Updating

Updates are automatic. When a new version is pushed, run:

```bash
/plugin install independent@jamespritchard-plugins
```

## Plugin Structure

```
independent/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata
├── commands/
│   └── independent.md    # The /independent command
├── hooks/
│   ├── hooks.json        # Hook configuration
│   ├── session-start.sh  # Session initialization
│   ├── pretooluse-hook.sh
│   ├── post-tool-use.sh
│   ├── stop-hook.sh      # Exit gate
│   └── subagentstart-hook.sh
└── scripts/
    └── setup-independent.sh
```

## License

MIT
