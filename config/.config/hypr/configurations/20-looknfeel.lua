hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 12,
		layout = "dwindle",
		border_size = 0,
	},

	animations = {
		enabled = true,
	},

	-- Layout
	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 0,
	},

	decoration = {
		rounding = 12,
		rounding_power = 4.0,
		active_opacity = 0.95,
		inactive_opacity = 0.90,

		blur = {
			enabled = true,
			size = 4,
			passes = 3,
		},

		shadow = {
			enabled = false,
			range = 10,
			render_power = 1,
			sharp = false,
			offset = { 0, 2 },
		},

		-- motion_blur = {
		-- 	enabled = true,
		-- },
	},
})