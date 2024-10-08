local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.window_decorations = "RESIZE"
config.hide_mouse_cursor_when_typing = false
config.color_scheme = "Brogrammer"

config.font = wezterm.font("MesloLGS NF")
config.freetype_load_flags = "NO_HINTING"
config.font_size = 11.0
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.warn_about_missing_glyphs = false

local act = wezterm.action
config.disable_default_key_bindings = true
config.leader = { key = "z", mods = "CTRL", timeout_milliseconds = 10000 }
config.keys = {
    { key = "z", mods = "LEADER|CTRL", action = act.SendKey({ key = "z", mods = "CTRL" }) },
    { key = ':', mods = "LEADER|SHIFT", action = act.ActivateCommandPalette },
    -- panes
    { key = 's', mods = "LEADER", action = act.SplitVertical },
    { key = 'v', mods = "LEADER", action = act.SplitHorizontal },
    { key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
    { key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
    { key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
    { key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
    -- tabs
    { key = "n", mods = "CTRL", action = act.SpawnTab("DefaultDomain") },
    { key = "H", mods = "ALT|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "L", mods = "ALT|SHIFT", action = act.ActivateTabRelative(1) },
}

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "ALT",
        action = act.ActivateTab(i - 1),
    })
end

config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = "Right" } },
        action = act.SelectTextAtMouseCursor("Block"),
        mods = "ALT",
    },
    {
        event = { Down = { streak = 3, button = "Left" } },
        action = act.SelectTextAtMouseCursor("SemanticZone"),
    },
}

return config
