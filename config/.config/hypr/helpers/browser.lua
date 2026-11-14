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

function M.get_default_browser_bin()
	local handle = io.popen("xdg-settings get default-web-browser")
	if not handle then
		return fallback
	end

	local desktop = handle:read("*a"):gsub("%s+", "")
	handle:close()
	if desktop == "" then
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
