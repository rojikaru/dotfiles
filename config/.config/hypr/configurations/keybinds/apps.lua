local function apply_binds(cmd_prefix, dict, secondary_mod, joiner)
	for _, bind in ipairs(dict) do
		local key, cmd = bind[1], bind[2]
		local joiner = joiner or " "
		local full_cmd = cmd_prefix .. joiner .. cmd

		local path
		if secondary_mod then
			path = MainMod .. " + " .. secondary_mod .. " + " .. key
		else
			path = MainMod .. " + " .. key
		end

		hl.bind(path, hl.dsp.exec_cmd(full_cmd))
	end
end

local special_app_binds = {
	{ "RETURN", TermEmulator },
	{ "B", "zen-browser" },
}
apply_binds("uwsm app --", special_app_binds)

local system_binds = {
	{ "R", "hypreload" },
	{ "F5", "hypreload" },
	{ "SHIFT + R", "wallset-backend-startup" },
	{ "L", "hyprlock" },
	{ "S", "toggle-hyprsunset" },
}
apply_binds("", system_binds)

local cli_binds = {
	{ "N", "nvim" },
	{ "T", "btop" },
	{ "D", "lazydocker" },
	{ "F", "yazi" },
}
apply_binds("uwsm app -- " .. TermEmulator .. " -e", cli_binds, "SHIFT")

local app_binds = {
	{ "B", "zen-browser" },
	{ "RETURN", "zen-browser" },
	{ "C", "code" },
	{ "M", "spotify" },
	{ "G", "steam" },
	{ "O", "discord" },
	{ "Y", "Telegram" },
	{ "Q", "killall" },
}
apply_binds("uwsm app --", app_binds, "SHIFT")

local launcher_binds = {
	{ "SPACE", "launcher" },
	{ "P", "battery-profile" },
	{ "SHIFT + W", "wallset" },
	{ "ALT + W", "waybar-menu" },
	{ "SHIFT + S", "screenshot area" },
	{ "SHIFT + E", "rofimoji-styled" },
	{ "SHIFT + X", "projectpick" },

	-- Copilot button on keyboard
	-- alternative: install keyd and rebind to right CTRL
	{ "SHIFT + F23", "projectpick" },
}
apply_binds("pkill rofi ||", launcher_binds)

local web_app_binds = {
	{ "I", "https://mail.google.com" },
	{ "L", "https://app.notion.com" },
	{ "P", "https://photos.google.com" },
	{ "SEMICOLON", "https://calendar.notion.com" },
}
apply_binds("uwsm app -- chromium --app=", web_app_binds, "SHIFT", "")
