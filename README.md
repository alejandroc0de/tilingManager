# tilingManager

A lightweight, keyboard-driven window manager for macOS, written in Swift.

tilingManager runs in the background and lets you move and resize the window you are working in with global keyboard shortcuts: snap it to the left or right half of the screen, maximize it, or minimize it. It works with multiple monitors and always acts on the screen the window is currently on.

The project is built to stay small and fast. It is a native Swift process with no Electron, no web views and no background polling, so its memory use stays low. That matters on machines with limited RAM.

## Features

- Snap the focused window to the left or right half of the screen
- Maximize the focused window to the usable screen area (without covering the menu bar or Dock)
- Minimize the focused window
- Multi-monitor support: actions apply to the screen that contains the window
- Global shortcuts that work in any app
- Runs as a background process with no Dock icon

## Keyboard shortcuts

| Shortcut                        | Action                  |
|---------------------------------|-------------------------|
| Control + Option + Left Arrow   | Move window to left half |
| Control + Option + Right Arrow  | Move window to right half |
| Control + Option + Up Arrow     | Maximize window         |
| Control + Option + Down Arrow   | Minimize window         |

## Requirements

- macOS 14 (Sonoma) or later
- Swift 5.9 or later (Xcode or the Xcode Command Line Tools)
- Accessibility permission (see below)

## Installation

Clone the repository and build it with Swift Package Manager:

```bash
git clone https://github.com/<your-username>/tilingManager.git
cd tilingManager
swift build
```

## Usage

Run the program:

```bash
swift run
```

The program prints a ready message and keeps running in the background, waiting for shortcuts. Switch to any app and use the shortcuts listed above. To stop it, go back to the terminal and press Control + C.

## Accessibility permission

macOS only lets an app move other apps' windows if it has Accessibility permission. The first time you run tilingManager, macOS shows a prompt asking for it.

1. Open System Settings > Privacy & Security > Accessibility.
2. Enable the app you are running tilingManager from. During development this is your terminal or editor (for example Terminal, iTerm or Visual Studio Code), because macOS grants the permission to the process that launches the program.
3. Quit that app completely and open it again. macOS checks the permission when a process starts, so an already running terminal keeps the old status.

If the permission is missing, the program prints a message and exits.

## How it works

tilingManager uses three macOS APIs:

- **Accessibility API (AXUIElement):** macOS has no public tiling API. Every app, window and control on screen is exposed as an accessibility element with attributes such as title, position, size and minimized state. tilingManager reads these attributes to find the focused window and writes the position and size attributes to move and resize it.
- **Carbon hotkeys (RegisterEventHotKey):** registers system-wide keyboard shortcuts. This is the standard way to create global hotkeys on macOS and does not require additional permissions.
- **AppKit (NSWorkspace, NSScreen, NSApplication):** finds the frontmost app, reads the size and layout of the connected screens, and runs the event loop that keeps the program alive and waiting for shortcuts.

When a shortcut is pressed, the program:

1. Finds the frontmost application.
2. Asks it for its focused window.
3. Reads the window's frame and finds the screen that contains the center of the window.
4. Calculates the target rectangle within that screen's usable area.
5. Writes the new position and size to the window.

### Coordinate systems

The Accessibility API and AppKit use different coordinate systems. Accessibility coordinates start at the top-left corner of the primary screen, with y increasing downward. AppKit screen coordinates start at the bottom-left corner of the primary screen, with y increasing upward. tilingManager converts between them by flipping around the height of the primary screen, which is what makes the calculations correct on every connected monitor.

## Project structure

```
tilingManager/
  Package.swift              Swift package manifest (macOS 14 minimum)
  Sources/tilingManager/
    main.swift               Entry point: permission check, hotkey registration, event loop
    AXHelpers.swift          Reading and writing window attributes through the Accessibility API
    WindowActions.swift      Window actions, screen detection and layout math
    HotKeys.swift            Global hotkey registration and event handling
  Tests/tilingManagerTests/  Unit tests
```

## Known limitations

- Windows in native full-screen mode cannot be moved or resized.
- Some apps enforce a minimum or fixed window size, so the window may not fill the exact target area.
- Minimized windows have to be restored from the Dock.
- Shortcuts are currently fixed in code and cannot be configured.
- The program runs from the terminal. It is not yet packaged as a standalone app.

## Roadmap

- More layouts: thirds, quarters, master and stack, grid
- Move windows between screens with a shortcut
- Configurable shortcuts through a config file
- Package as a menu bar app with launch at login
- Memory profiling to keep idle memory use as low as possible

## Contributing

This is a personal learning project, but issues and suggestions are welcome. Feel free to open an issue or a pull request.
