hl.bind("CTRL + ALT + DELETE", hl.dsp.exec_cmd("killall"))
hl.bind("CTRL + SHIFT + ESCAPE", hl.dsp.exec_cmd("kitty -e btop"))

hl.bind(MainMod .. " + ALT + M", hl.dsp.exec_cmd("hyprshutdown --post-cmd 'uwsm stop'"))

if hl.plugin and hl.plugin.hyprexpo then
	hl.bind("SUPER + TAB", function()
		hl.plugin.hyprexpo.expo("toggle")
	end)
end

-- Bind default CTRL hotkeys to SUPER keys

hl.bind(MainMod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert", window = "activewindow" }))
hl.bind(MainMod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert", window = "activewindow" }))
hl.bind(MainMod .. " + SHIFT + Z", hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "Z", window = "activewindow" }))

local super_passthrough_binds = { "X", "A", "Z" }
for _, key in ipairs(super_passthrough_binds) do
	hl.bind(
		MainMod .. " + " .. key,
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = key,
			window = "activewindow",
		})
	)
end
