# Caelestia Shell Keybinds Plugin

An interactive keybind searcher and trigger tool for **Caelestia Shell** and **Hyprland**, powered by `fzf` and styled dynamically with Caelestia's active Material You color palette.

---

## Features

- 🔍 **Dynamic Discovery**: Reads default keybinds from `~/.config/hypr/variables.lua` and `~/.config/hypr/hyprland/keybinds.lua`.
- ⚙ **User Overrides & Binds**: Automatically incorporates variable overrides from `~/.config/caelestia/hypr-vars.lua` (e.g. custom browser, editor, or key combinations) and user-defined keybinds and unbinds from `~/.config/caelestia/hypr-user.lua`.
- 📝 **Intelligent Descriptions**:
  - Automatically resolves human-readable names for standard Caelestia shortcuts, workspaces, and window actions.
  - Automatically extracts comments directly preceding `hl.bind(...)` in `hypr-user.lua` as custom descriptions.
  - Supports `flags.description` if present.
- 🎨 **Material You Theming**: Dynamically extracts the active color scheme from `~/.config/hypr/scheme/current.lua` and themes `fzf` colors, borders, and prompts to match Caelestia.
- 🚀 **Instant Trigger on Enter**:
  - **Shell commands**: Dispatched detached in the background.
  - **Hyprland dispatchers / Lua functions**: Evaluated instantly via `hyprctl eval`.
  - **Mouse binds**: Displays an informational Caelestia desktop notification.
- 🖥 **TTY & GUI Aware**:
  - If executed inside a terminal (e.g., `foot`, `fish`, `bash`), runs directly in-place.
  - If executed via GUI, hotkey, or Caelestia launcher, opens a centered floating `foot` window with window rules (`class = caelestia-keybinds`).

---

## Usage

### 1. Hotkey
Press **`SUPER + /`** to summon the floating keybinds searcher anytime.
*(Configured in `~/.config/caelestia/hypr-user.lua` to launch in `foot` with floating tag `+float_60_70`)*

### 2. Caelestia Shell Launcher
1. Open the launcher with **`SUPER`**.
2. Type `> Keybinds` or search for `keybinds`.
3. Press **`Enter`** to open the interactive fuzzy finder in a floating foot window.

### 3. Command Line
```bash
# Launch interactive fzf searcher
caelestia-keybinds

# Print all active keybinds to stdout
caelestia-keybinds --list

# Output raw structured JSON
caelestia-keybinds --json

# Preview card for a specific keybind ID
caelestia-keybinds --preview <id>

# Directly trigger the action of a keybind ID
caelestia-keybinds --trigger <id>
```

---

## File Structure

```
~/.config/caelestia/plugins/keybinds/
├── plugin.json               # Plugin metadata & entrypoints
├── extractor.lua             # Lua extraction bridge (mocks hl & fn)
├── caelestia_keybinds.py     # Python controller, theme parser & fzf runner
└── README.md                 # Documentation

~/.local/bin/
└── caelestia-keybinds        # Symlink to caelestia_keybinds.py

~/.config/fish/functions/
└── caelestia-keybinds.fish   # Fish shell wrapper function
```

---

## Adding Custom Keybinds

In `~/.config/caelestia/hypr-user.lua`, you can add comments above your custom binds to give them clear descriptions:

```lua
-- Open personal workspace notes
hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd("obsidian"))
```

The plugin will automatically detect the comment and display `Open personal workspace notes` in the fuzzy finder.
