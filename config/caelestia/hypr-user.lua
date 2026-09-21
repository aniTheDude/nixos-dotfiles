-- Pass mouse button 280 through to Discord (handles press and release automatically)
hl.bind("mouse:280", hl.dsp.pass({ window = "class:^(discord)$" }), { ignore_mods = true, non_consuming = true })

-- =============================================================================
-- Restored User Input & Keybind Preferences
-- =============================================================================
hl.config({
	input = {
		kb_options = "compose:ralt",
		accel_profile = "flat",
	},
})
hl.unbind("caps")

-- =============================================================================
-- Caelestia Keybinds Plugin
-- =============================================================================
hl.window_rule({
	match = { class = "caelestia-keybinds" },
	tag = "+float_60_70",
})

local home = os.getenv("HOME") or "/home/ani"

-- Fuzzy keybinds searcher
hl.bind(
	"SUPER + slash",
	hl.dsp.exec_cmd("foot -a caelestia-keybinds -T 'Caelestia Keybinds' " .. home .. "/.local/bin/caelestia-keybinds")
)

-- hl.bind("SUPER + ALT + M", hl.dsp.exec_cmd("/home/ani/.local/bin/toggle-monitor.sh"))

--Change window layout
hl.bind("SUPER + A", hl.dsp.layout("togglesplit"))
