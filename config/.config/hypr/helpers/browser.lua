local M = {}

local home = os.getenv("HOME") or ""
local dirs = {
	home .. "/.local/share/applications/",
	"/usr/local/share/applications/",
	"/usr/share/applications/",
	"/var/lib/flatpak/exports/share/applications/",
	"/var/lib/snapd/desktop/applications/",
}

local fallback = "firefox"

local function default_browser_desktop()
	local f = io.open(home .. "/.config/mimeapps.list")
	if not f then
		return nil
	end
	local in_defaults, desktop = false, nil
	for line in f:lines() do
		local section = line:match("^%[(.+)%]$")
		if section then
			in_defaults = section == "Default Applications"
		elseif in_defaults then
			desktop = line:match("^x%-scheme%-handler/https=([^;]+)")
			if desktop then
				break
			end
		end
	end
	f:close()
	return desktop
end

function M.get_default_browser_bin()
	local desktop = default_browser_desktop()
	if not desktop then
		return fallback
	end

	for _, dir in ipairs(dirs) do
		local file = io.open(dir .. desktop, "r")
		if not file then
			goto continue
		end

		for line in file:lines() do
			local exec_cmd = line:match("^Exec=(.+)")
			if exec_cmd then
				file:close()
				exec_cmd = exec_cmd:gsub("%%[a-zA-Z]", "")
				local bin = exec_cmd:match('^"([^"]+)"') or exec_cmd:match("^(%S+)")
				return bin or fallback
			end
		end

		::continue::
	end

	return fallback
end

return M
