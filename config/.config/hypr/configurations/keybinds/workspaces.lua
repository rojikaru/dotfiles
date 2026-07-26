for i = 1, 10 do
	local key = i % 10 -- Workspace 10 maps to key 0
	hl.bind(MainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(MainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

special_workspace_binds = {
	{ "COMMA", "notes" },
	{ "PERIOD", "term" },
	{ "SLASH", "browser" },
}
for _, bind in ipairs(special_workspace_binds) do
	local key, workspace = bind[1], bind[2]
	hl.bind(MainMod .. " + " .. key, hl.dsp.workspace.toggle_special(workspace))
	hl.bind(MainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ 
		workspace = "special:" .. workspace, 
		follow = false
	}))
end