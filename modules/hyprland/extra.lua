hl.monitor({
  output = "DP-1",
  mode = "1920x1080@144",
  position = "1920x0",
  scale = 1,
})

hl.monitor({
  output = "DP-2",
  mode = "1920x1080@144",
  position = "0x0",
  scale = 1,
})

hl.config({
    master = {
        new_on_top = true,
    },
    general = {
        layout = "master",
    },
})

local mainMod = "SUPER"
local terminal = "kitty"
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("librewolf"))

-- Resizing
hl.bind(mainMod .. " + h",  hl.dsp.window.resize({ x = "-80", y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + l",  hl.dsp.window.resize({ x = "+80", y = 0, relative = true }), { repeating = true })

hl.bind(mainMod .. " + k",    hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + j",    hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + SHIFT + k",    hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + SHIFT + j",    hl.dsp.layout("swapnext"))

hl.bind(mainMod .. " + z",    hl.dsp.focus({direction = "left"}))
hl.bind(mainMod .. " + x",    hl.dsp.focus({direction = "right"}))

hl.bind(mainMod .. " + SHIFT + d", hl.dsp.focus({ window = "nil" }))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + q", hl.dsp.window.close())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + b", hl.dsp.window.fullscreen({ action = "toggle" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.config({
    input = {
        kb_layout  = "se",
        kb_variant = "us",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

