# notif

Minimal macOS Notification Center controller for keyboard shortcuts.

## Features

- **Expand** notification stack
- **Collapse** notification stack
- **Click** first notification (opens source app)
- **Close** first notification (dismiss without action)

Single-file AppleScript architecture optimized for keyboard-driven workflows.

## Installation

### Homebrew

```bash
brew tap zukash/tap
brew install notif
```

### Manual

```bash
git clone https://github.com/zukash/notif.git
cd notif
chmod +x notif
ln -s "$(pwd)/notif" /usr/local/bin/notif
```

## Usage

```bash
# Expand notification stack (stays expanded)
notif expand

# Collapse to stack view
notif collapse

# Click first notification (assumes already expanded)
notif click

# Close first notification (assumes already expanded)
notif close
```

## Keyboard Shortcuts

Use with keyboard shortcut tools like:
- [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
- [BetterTouchTool](https://folivora.ai/)
- [Hammerspoon](https://www.hammerspoon.org/)

Example Karabiner configuration:
```json
{
  "type": "basic",
  "from": { "key_code": "n", "modifiers": { "mandatory": ["command", "shift"] } },
  "to": [{ "shell_command": "/usr/local/bin/notif expand" }]
}
```

## Design Philosophy

- **Minimal feature set**: Only what's needed for keyboard shortcuts
- **First notification only**: No indexing complexity
- **No automatic state management**: User controls expand/collapse explicitly
- **Single file**: Easy to read, debug, and maintain
- **Keyboard-first**: Optimized for rapid keyboard-driven workflows

## Architecture

```
notif (37 lines)          # Bash wrapper - command routing only
notif.applescript (203 lines)  # All AppleScript logic
```

All logic in a single AppleScript file with clear structure:
- Constants (process names, UI element roles)
- Common handlers (window/notification access)
- Command handlers (expand/collapse/click/close)
- Entry point (command dispatcher)

## Requirements

- macOS (tested on macOS 13+)
- Accessibility permissions for Terminal/iTerm2

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Issues and pull requests are welcome!
