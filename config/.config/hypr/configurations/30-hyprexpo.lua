if not hl.plugin or not hl.plugin.hyprexpo then
    return
end

-- Vim Motion binds for navigation
hl.define_submap("hyprexpo", function()
	hl.bind("h", function()
		hl.plugin.hyprexpo.kb_focus("left")
	end)
	hl.bind("l", function()
		hl.plugin.hyprexpo.kb_focus("right")
	end)
	hl.bind("k", function()
		hl.plugin.hyprexpo.kb_focus("up")
	end)
	hl.bind("j", function()
		hl.plugin.hyprexpo.kb_focus("down")
	end)
	hl.bind("return", function()
		hl.plugin.hyprexpo.kb_confirm()
	end)
	hl.bind("escape", function()
		hl.plugin.hyprexpo.expo("cancel")
	end)
end)

-- Gesture
hl.plugin.hyprexpo.gesture({
	fingers = 3,
	direction = "up",
	action = "expo",
})

-- Look and feel
hl.config({
	plugin = {
		hyprexpo = {
			columns = 3,
			gaps_in = 5,
			gaps_out = 0,
			bg_col = "rgb(111111)",
			workspace_method = "center first",
			gesture_distance = 200,
			cancel_key = "escape",
			show_cursor = 1,
			skip_empty = 0,
			max_workspace = 10,
		},
	},
})