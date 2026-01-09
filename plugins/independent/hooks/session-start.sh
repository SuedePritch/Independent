#!/bin/bash
# SessionStart hook - clears session log
# Ensures each session starts fresh without stale agent invocation records

SESSION_LOG="${CLAUDE_PROJECT_ROOT:-$PWD}/.claude/.session-actions.log"
rm -f "$SESSION_LOG"
exit 0
