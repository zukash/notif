# notif

Minimal macOS Notification Center controller for keyboard shortcuts.

## Features

- **Expand** notification stack
- **Collapse** notification stack
- **Toggle** between expand/collapse
- **Click** first notification (opens source app)
- **Close** first notification (dismiss without action)

Native Objective-C implementation optimized for speed and keyboard-driven workflows.

## Installation

### Homebrew

```bash
brew install zukash/tap/notif
```

### Manual

```bash
git clone https://github.com/zukash/notif.git
cd notif

# Build and install
make
sudo make install

# Or build and install manually
make
cp notif /usr/local/bin/

# Uninstall
sudo make uninstall
```

**Build options:**
```bash
make           # Build universal binary (arm64 + x86_64)
make clean     # Remove compiled binary
make test      # Build and run tests
make install   # Install to /usr/local/bin
make uninstall # Remove from /usr/local/bin
```

## Usage

```bash
# Show help
notif --help

# Show version
notif --version

# Expand notification stack (stays expanded)
notif expand

# Collapse to stack view
notif collapse

# Toggle between expand/collapse
notif toggle

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
  "to": [{ "shell_command": "$(brew --prefix)/bin/notif expand" }]
}
```

## Design Philosophy

- **Minimal feature set**: Only what's needed for keyboard shortcuts
- **First notification only**: No indexing complexity
- **No automatic state management**: User controls expand/collapse explicitly
- **Single file**: Easy to read, debug, and maintain
- **Keyboard-first**: Optimized for rapid keyboard-driven workflows
- **Native speed**: ~0.04s execution time via Objective-C

## Architecture

Single-file Objective-C implementation (~310 lines):

```
notif.m        # All logic in one file
  ├─ UI element traversal (depth-limited recursion)
  ├─ Command handlers (expand/collapse/toggle/click/close)
  └─ Entry point (command dispatcher with help/version)
```

Uses macOS ApplicationServices framework for direct UI automation without AppleScript overhead.

## Requirements

- macOS (tested on macOS 13+)
- Xcode Command Line Tools (for compilation)
- Accessibility permissions for Terminal/iTerm2 (for execution)

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Issues and pull requests are welcome!
