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

-- Laptop montior
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  scale = 1,
})

hl.config({
    master = {
        new_on_top = true,
        new_status = "master",
    },
    general = {
        layout = "master",
    },
})

hl.animation({leaf = "global", enabled = false})

local mainMod = "SUPER"
local terminal = "foot"
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + y", hl.dsp.exec_cmd("librewolf"))
hl.bind(mainMod .. " + f", hl.dsp.exec_cmd("pcmanfm-qt"))

-- Magnifier
hl.bind(mainMod .. " + SHIFT + m", hl.dsp.exec_cmd('TMP=$(mktemp); grim -g "$(slurp)" - > $TMP; imv -u nearest_neighbour $TMP; rm $TMP'))

--riverctl map normal Super+Shift M spawn '
--  TMP=$(mktemp); grim -g "$(slurp)" - > $TMP; imv -u nearest_neighbour $TMP; rm $TMP
--'

-- Resizing
hl.bind(mainMod .. " + h",  hl.dsp.window.resize({ x = "-80", y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + l",  hl.dsp.window.resize({ x = "+80", y = 0, relative = true }), { repeating = true })

hl.bind(mainMod .. " + k",    hl.dsp.layout("cycleprev"))
hl.bind(mainMod .. " + j",    hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + SHIFT + k",    hl.dsp.layout("swapprev"))
hl.bind(mainMod .. " + SHIFT + j",    hl.dsp.layout("swapnext"))

hl.bind(mainMod .. " + z",    hl.dsp.focus({direction = "left"}))
hl.bind(mainMod .. " + x",    hl.dsp.focus({direction = "right"}))

hl.bind(mainMod .. " + SHIFT + z", hl.dsp.window.move({monitor = "-1"}))
hl.bind(mainMod .. " + SHIFT + x", hl.dsp.window.move({monitor = "+1"}))

hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))

hl.bind(mainMod .. " + q", hl.dsp.window.close())

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.workspace_rule({ workspace = "r~" .. tostring(i), persistent = true })
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = "r~" .. tostring(key)}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = "r~" .. tostring(key) }))
end
hl.workspace_rule({ workspace = "DP-1/" .. 2, monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "DP-1/" .. 1, monitor = "DP-2", default = true })

hl.bind(mainMod .. " + b", hl.dsp.window.fullscreen({ action = "toggle" }))

-- TODO check if this works
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + d",   hl.dsp.exec_cmd("rofi -show drun"))

-- Project selector
hl.bind(mainMod .. " + p",   hl.dsp.exec_cmd('dir=$(ls ~/Projects/ | rofi -dmenu -p "Choose project: ") && foot sh -c "cd ~/Projects/$dir && tmux attach -t $dir || tmux new -s $dir"'))
-- Open notes
hl.bind(mainMod .. "+ SHIFT + p",   hl.dsp.exec_cmd('foot sh -c "cd ~/Notes/ && tmux attach -t notes || tmux new -s notes $EDITOR"'))

hl.bind(mainMod .. " + s",   hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(mainMod .. " + r",   hl.dsp.exec_cmd('grim - | wl-copy'))
hl.bind(mainMod .. "+ SHIFT + r",   hl.dsp.exec_cmd('grim'))
hl.bind(mainMod .. "+ ALT + s",   hl.dsp.exec_cmd('tmp="$(mktemp)" ; grim -g "$(slurp -d)" - > "$tmp" && tesseract $tmp - --psm 3 -l eng+swe | wl-copy'))

hl.config({
    general = {
        border_size = 3,
        gaps_in = 0,
        gaps_out = 0,
        resize_on_border = true,
        hover_icon_on_border = false,
    },
    decoration = {
      blur = {
          enabled = false,
      },
      shadow = {
          enabled = false,
      },
    },
    input = {
        kb_layout  = "se",
        kb_variant = "us",
        kb_model   = "",
        kb_options = "caps:escape",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
            middle_button_emulation = true,
            clickfinger_behavior = true,
        },
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

