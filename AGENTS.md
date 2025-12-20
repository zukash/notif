# Agent Guidelines for notif

## Project Overview
Minimal macOS Notification Center controller for keyboard shortcuts. Single-file Objective-C implementation designed for speed, simplicity, and keyboard-driven workflows.

## Purpose
Control notifications via keyboard shortcuts with 5 essential commands:
- Expand notification stack
- Collapse notification stack
- Toggle between expand/collapse
- Click first notification (opens source app)
- Close first notification (dismiss without action)

## Directory Structure
```
notif.m         # Objective-C source (all logic in ~310 lines)
notif           # Compiled universal binary (arm64 + x86_64)
AGENTS.md       # This file
README.md       # User documentation
LICENSE
```

## Commands
All commands operate on the **first notification** only (no indexing):

- `./notif expand` - Expand notification stack, stays expanded
- `./notif collapse` - Collapse to stack view
- `./notif toggle` - Toggle between expand/collapse
- `./notif click` - Click first notification (assumes expanded)
- `./notif close` - Close first notification (assumes expanded)
- `./notif --help` - Show usage information
- `./notif --version` - Show version

## Testing
- **Manual testing**: `./notif <command>` with actual notifications
- **Compilation test**: `make` or direct `clang` compilation
- **Expected behavior**:
  - `click`/`close` assume notifications are already expanded
  - No automatic collapse after operations
  - Silent execution (no output on success)
  - Help/error messages to stderr

## Code Style

### Objective-C (notif.m)

**Structure:**
```c
// Version & Constants
// Helper functions (getNotificationWindow, getButtons, etc.)
// Command handlers (handleExpand, handleCollapse, handleToggle, handleClick, handleClose)
// UI functions (showUsage, showVersion)
// Entry point (main - command dispatcher)
```

**Conventions:**
- **Constants**: `#define VERSION "1.0.0"` and `static NSString * const PROCESS_NAME`
- **Full word variable names**: `element` (not `elem`), `notification` (not `notif`)
- **Function naming**: `handleCommandName()` for commands, descriptive names for utilities
- **Memory management**: Proper CFRetain/CFRelease, use ARC with `-fobjc-arc`
- **Error handling**: Silent on success, no verbose logging
- **Return values**: void for most handlers (side effects only)

**Key Functions:**
- `getNotificationWindow()` - Returns AXUIElementRef to first window or NULL
- `getButtons(element, depth)` - Recursive traversal (max depth 4) to find all buttons
- `getSubrole(element)` - Returns subrole string or nil
- `isExpanded(buttons)` - Check if any button has SUBROLE_ALERT
- `getFirstNotification(buttons)` - Find topmost notification by Y position
- `clickElement(element)` - Perform AXPress action
- `handleExpand/Collapse/Toggle/Click/Close()` - Command implementations
- `showUsage()` - Display help message
- `showVersion()` - Display version

**Constants:**
- `VERSION` - "1.0.0"
- `PROCESS_NAME` - "Notification Center" (with space)
- `SUBROLE_ALERT` - "AXNotificationCenterAlert"  
- `SUBROLE_STACK` - "AXNotificationCenterAlertStack"

**Frameworks:**
- `Foundation.framework` - Core Objective-C classes
- `AppKit.framework` - macOS UI elements
- `ApplicationServices.framework` - Accessibility APIs (AXUIElement)

## Architecture
Single-file Objective-C architecture:
- All logic in one file (~310 lines)
- Direct use of ApplicationServices framework for UI automation
- Depth-limited recursive traversal (max 4 levels) for performance
- Universal binary compilation (arm64 + x86_64)
- ~0.04s execution time (10x faster than AppleScript)

## Compilation

```bash
# Universal binary (recommended for distribution)
clang -o notif notif.m \
  -framework Foundation \
  -framework ApplicationServices \
  -framework AppKit \
  -fobjc-arc \
  -arch arm64 -arch x86_64

# Single architecture (faster compilation)
clang -o notif notif.m \
  -framework Foundation \
  -framework ApplicationServices \
  -framework AppKit \
  -fobjc-arc
```

## Design Philosophy
- **Minimal feature set**: Only what's needed for keyboard shortcuts
- **First notification only**: No indexing complexity
- **No automatic state management**: User controls expand/collapse explicitly
- **Single file**: Easy to read, debug, and maintain
- **Keyboard-first**: Optimized for rapid keyboard-driven workflows
- **Native speed**: Direct C API access, no AppleScript overhead
- **Silent operation**: No output on success, only on error or help

## Performance
- **Execution time**: ~0.04 seconds (compared to 0.5-0.7s for AppleScript)
- **Optimization techniques**:
  - Depth-limited recursion (max 4 levels)
  - Direct C API usage (no AppleScript layer)
  - Minimal memory allocations
  - ARC for automatic memory management

## Error Handling
Silent operation by default:
- Success: No output
- Failure: Silent (returns without action if no window/notifications)
- Help requested: Display usage to stderr
- Invalid command: Display error + usage to stderr

## What This Is NOT
- Not a notification counter
- Not a bulk manager  
- Not index-based (only first notification)
- Not verbose (silent on success)
- Not dependent on external scripts (single binary)
