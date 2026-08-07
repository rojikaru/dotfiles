hl.on("hyprland.start", function()
	local commands = {
		"dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland",
		"systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
		"gnome-keyring-daemon --start --components=secrets",
		"hyprpm reload",
		"uwsm app -- /usr/lib/polkit-kde-authentication-agent-1",
		"uwsm app -- awww-daemon",
		"uwsm app -- hyprsunset-init",
		"uwsm app -- configwatch",
		"uwsm app -- swaync",
		"uwsm app -- waybar",
	}
	for _, cmd in ipairs(commands) do
		hl.exec_cmd(cmd)
	end
end)
