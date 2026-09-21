# Caelestia HeadsetControl Battery Plugin

A Caelestia Shell plugin that integrates `headsetcontrol` battery telemetry directly onto the Caelestia sidebar.

---

## Features

- 🎧 **Device Auto-Detection**: Automatically detects connected headsets supported by `headsetcontrol` (e.g. SteelSeries Arctis 7/Pro, Logitech, Corsair, HyperX, etc.).
- 🔋 **Live Battery Telemetry**:
  - Exact battery percentage
  - Dynamic battery status icon matching Caelestia Material You styling
  - Remaining battery life runtime estimation (e.g. `~4h 55m remaining`)
  - Charging state detection & visual indicator
  - Smooth animated battery progress level bar
- 🎛 **ChatMix Dial Support**: Displays current game/chat balance for headsets with ChatMix capabilities (such as SteelSeries Arctis 7).
- 🔄 **Smart Refreshing**:
  - Instant auto-refresh whenever the sidebar is opened (`SUPER + N` or drawer gesture)
  - 30-second periodic background polling
  - Manual one-tap refresh button with animated spinner
- 🎨 **Material Design 3 Integration**: Uses Caelestia's active theme tokens (`Tokens`, `Colours.tPalette`, `MaterialIcon`) for seamless native UI aesthetics.

---

## Architecture & Files

```
~/.config/caelestia/plugins/headsetcontrol/
├── plugin.json               # Plugin metadata & declaration
├── HeadsetBattery.qml         # Sidebar card component with headsetcontrol telemetry
└── README.md                 # Plugin documentation

~/.config/quickshell/caelestia/
└── modules/sidebar/Content.qml  # Sidebar layout loading the plugin
```

---

## Configuration

The plugin uses `headsetcontrol -o json` to communicate with the headset via HID without requiring root privileges (assuming standard udev rules provided by `headsetcontrol`).

To manually test headset output in your terminal:
```bash
headsetcontrol -o json
```
