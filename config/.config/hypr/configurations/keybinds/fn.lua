-- Power menu
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("pkill rofi || powermenu"))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd("screenshot fullscreen"))
hl.bind("CTRL + PRINT", hl.dsp.exec_cmd("screenshot area"))
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("screenshot draw"))

-- Audio
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ -l 1"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- -l 0"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))

-- mute mic
hl.bind("XF86Launch2", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"))

-- Brightness
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set --min-value=1 5%-"))

-- Apps
hl.bind("XF86Calculator", hl.dsp.exec_cmd("uwsm app -- gnome-calculator"))
