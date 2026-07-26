-- Window behavior
hl.bind(MainMod .. " + Q", hl.dsp.window.close())
hl.bind(MainMod .. " + W", hl.dsp.window.close())
hl.bind(MainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(MainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Mouse
hl.bind(MainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(MainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Keyboard resize
hl.bind(MainMod .. " + MINUS", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(MainMod .. " + SHIFT + MINUS", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))
hl.bind(MainMod .. " + EQUAL", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(MainMod .. " + SHIFT + EQUAL", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))

-- Keyboard move
hl.bind(MainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(MainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(MainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(MainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))

-- Switch in-between the windows
hl.bind("ALT + TAB", hl.dsp.window.cycle_next())
hl.bind(MainMod .. " + ALT + TAB", hl.dsp.window.cycle_next({ next = false }))

-- Dwindle
hl.bind(MainMod .. " + J", hl.dsp.layout("swapsplit"))