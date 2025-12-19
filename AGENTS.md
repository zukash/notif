# Agent Guidelines for notif

## Project Overview
Minimal macOS Notification Center controller for keyboard shortcuts. Single-file AppleScript with Bash wrapper, designed for simplicity and keyboard-driven workflows.

## Purpose
Control notifications via keyboard shortcuts with 4 essential commands:
- Expand notification stack
- Collapse notification stack  
- Click first notification (opens source app)
- Close first notification (dismiss without action)

## Directory Structure
```
notif                # Bash wrapper (37 lines) - command routing only
notif.applescript    # All AppleScript logic (203 lines) - single consolidated file
AGENTS.md           # This file
```

## Commands
All commands operate on the **first notification** only (no indexing):

- `./notif expand` - Expand notification stack, stays expanded
- `./notif collapse` - Collapse to stack view
- `./notif click` - Click first notification (assumes expanded)
- `./notif close` - Close first notification (assumes expanded)

## Testing
- **Manual testing**: `./notif <command>` with actual notifications
- **Direct AppleScript test**: `osascript notif.applescript expand`
- **Expected behavior**:
  - `click`/`close` assume notifications are already expanded
  - No automatic collapse after operations
  - Simple error: "No notifications" for all failure cases

## Code Style

### Bash (notif)
- Use `#!/bin/bash` shebang
- SCREAMING_SNAKE_CASE for variables: `SCRIPT_DIR`
- Double-quote all variables: `"$SCRIPT_DIR"`
- Simple `case` statement for 4 commands
- Direct `osascript` call (no file concatenation)

### AppleScript (notif.applescript)

**Structure:**
```applescript
-- Constants (property declarations)
-- Common handlers (shared functions)
-- Command handlers (handleExpand, handleCollapse, handleClick, handleClose)
-- Entry point (on run argv - command dispatcher)
```

**Conventions:**
- **Constants as properties**: `property PROCESS_NAME : "NotificationCenter"`
- **Full word variable names**: `element` (not `elem`), `notification` (not `notif`)
- **Consistent delays**: Use `DEFAULT_DELAY` (0.3 seconds) after UI interactions
- **Record return format**: `{notification:element, errorMsg:string}`
- **System Events pattern**: `tell application "System Events"` → `tell process PROCESS_NAME`
- **Handler naming**: `handleCommandName()` for commands, descriptive names for utilities
- **Error handling**: Simple string errors, prefer "No notifications" for missing data

**Key Handlers:**
- `getNotificationWindow()` - Returns first window or missing value
- `getFirstNotification(theWindow)` - Returns first alert element (no indexing)
- `clickElementBySubrole(theWindow, subrole)` - Generic click by subrole
- `performCloseAction(notification)` - Execute close action on notification
- `handleExpand/Collapse/Click/Close()` - Command implementations

**Constants to use:**
- `PROCESS_NAME` - "NotificationCenter"
- `SUBROLE_ALERT` - "AXNotificationCenterAlert"  
- `SUBROLE_STACK` - "AXNotificationCenterAlertStack"
- `ACTION_CLOSE` - "Close"
- `DEFAULT_DELAY` - 0.3

## Architecture
Single-file AppleScript architecture:
- All logic in one file (~200 lines)
- Constants at top for maintainability
- Common handlers for code reuse
- Command handlers call common handlers with `my handlerName()`
- Entry point dispatches commands via `on run argv`
- Bash script simply routes to `osascript notif.applescript <command>`

## Design Philosophy
- **Minimal feature set**: Only what's needed for keyboard shortcuts
- **First notification only**: No indexing complexity
- **No automatic state management**: User controls expand/collapse explicitly
- **Simple errors**: "No notifications" is sufficient for most cases
- **Single file**: Easy to read, debug, and maintain
- **Keyboard-first**: Optimized for rapid keyboard-driven workflows

## Error Messages
Simple, consistent errors:
- "No notifications" - Window missing or no alerts found
- "No notification stack found" - Stack element doesn't exist (expand fails)
- "Already collapsed or no notifications" - Nothing to collapse
- "Error: Close action not found" - Notification missing close action

## What This Is NOT
- Not a notification counter (removed `count` command)
- Not a bulk manager (removed `clear` command)  
- Not index-based (removed N-th notification support)
- Not a complex multi-file system (consolidated to single file)
