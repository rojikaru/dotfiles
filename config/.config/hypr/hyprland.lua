-- ╔══════════════════════════════════════╗
-- ║        HYPRLAND MAIN CONFIG          ║
-- ║     https://wiki.hyprland.org/       ║
-- ╚══════════════════════════════════════╝

-- Load all configuration modules from the "hypr/configurations" directory
-- Just add any additional configuration files in that directory and 
-- they will be automatically loaded after restarting Hyprland.

MainMod = "SUPER"
TermEmulator = os.getenv("TERMINAL") or "kitty"

local conf_dir = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
local modules_dir = conf_dir .. "/hypr/configurations"

local handle = io.popen('find "' .. modules_dir .. '" -maxdepth 2 -name "*.lua" | sort')
if handle then
	for path in handle:lines() do
		local ok, err = pcall(function()
			local chunk = assert(loadfile(path))
			chunk()
		end)
		if not ok then
			hl.notification.create({
				text = "Failed to load " .. path .. ": " .. tostring(err),
				timeout = 5000,
				icon = 3, -- error
				font_size = 28,
			})
		end
	end
	handle:close()
end
