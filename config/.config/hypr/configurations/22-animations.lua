hl.curve("MySmooth", { type = "bezier", points = { { 0.125, 0.706 }, { 0.245, 0.955 } } })
hl.curve("overshoot", { type = "bezier", points = { { 0, 1.6 }, { 0.28, 1 } } })
hl.curve("smooth", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "default", style = "slide" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "MySmooth", style = "slide" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "smooth", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "MySmooth", style = "slidevert" })

-- Layer Rules
hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.7 })
hl.layer_rule({ match = { namespace = "waybar" }, blur = true, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "swaync-notification-window" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "swaync-control-center" }, animation = "slide right" })
hl.layer_rule({ match = { namespace = "awww-daemon" }, animation = "fade" })

hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "MySmooth", style = "slide" })
