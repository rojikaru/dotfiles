-- Special workspaces

hl.window_rule({
	workspace = "special:notes",
	border_color = "rgb(f6c177)",
	border_size = 2,
})

hl.window_rule({
	workspace = "special:term",
	border_color = "rgb(9ccfd8)",
	border_size = 2,
})

hl.window_rule({
	workspace = "special:browser",
	border_color = "rgb(eb6f92)",
	border_size = 2,
})

-- Per-app customization

hl.window_rule({ match = { class = "org.oe-f.openboard" }, no_blur = true })

hl.window_rule({
	match = {
		class = "^(jetbrains-.*|android-studio)$",
		title = "^(win[0-9]+)$",
	},
	float = true,
	decorate = true,
})

hl.window_rule({
	match = {
		class = "DesktopEditors",
	},
	float = true,
	center = true,
	workspace = "unset",
})

hl.window_rule({
	match = {
		class = "steam",
	},
	float = true,
	decorate = true,
})

hl.window_rule({
	match = {
		class = ".*[Cc]alculator.*",
	},
	float = true,
	decorate = true,
})

-- Workspace rules

hl.config({
	misc = {
		focus_on_activate = true,
	}
})
