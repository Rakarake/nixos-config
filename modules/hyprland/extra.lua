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
local terminal = "footclient"
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + y", hl.dsp.exec_cmd("librewolf"))
hl.bind(mainMod .. " + f", hl.dsp.exec_cmd("pcmanfm"))

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
    hl.workspace_rule({ workspace = tostring(i), default_name = tostring(i), monitor = "DP-1", persistent = true })
    hl.workspace_rule({ workspace = tostring(i + 10), default_name = tostring(i), monitor = "DP-2", persistent = true })
    hl.workspace_rule({ workspace = tostring(i + 20), default_name = tostring(i), monitor = "eDP-2", persistent = true })
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = "r~" .. tostring(i)}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = "r~" .. tostring(i) }))
end

hl.bind(mainMod .. " + b", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Media keys
local ipc = "noctalia msg"
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind(mainMod .. "+ ALT + k", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind(mainMod .. "+ ALT + j", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind(mainMod .. "+ ALT + m", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind(mainMod .. "+ ALT + n", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind(mainMod .. "+ ALT + p", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind(mainMod .. "+ ALT + l", hl.dsp.exec_cmd("playerctl next"))
hl.bind(mainMod .. "+ ALT + h", hl.dsp.exec_cmd("playerctl previous"))

-- Network
hl.bind(mainMod .. "+ m", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center network"))
hl.bind(mainMod .. "+ CTRL + m", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center bluetooth"))

-- Lock screen
hl.bind(mainMod .. "+ ESCAPE", hl.dsp.exec_cmd(ipc .. " session lock"))
hl.bind(mainMod .. "+ ALT + SHIFT + s", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind(mainMod .. "+ ALT + SHIFT + r", hl.dsp.exec_cmd("systemctl reboot"))
hl.bind(mainMod .. "+ ALT + SHIFT + n", hl.dsp.exec_cmd("systemctl suspend"))
hl.bind(mainMod .. "+ ALT + SHIFT + e", hl.dsp.exec_cmd("hyprctl exit"))

-- Laptop lid close
hl.bind("switch:Lid Switch", hl.dsp.exec_cmd(ipc .. " session lock"), { locked = true })

-- clipboard
hl.bind(mainMod .. "+ c", hl.dsp.exec_cmd(ipc .. " panel-toggle clipboard"))
hl.bind(mainMod .. "+ SHIFT + c", hl.dsp.exec_cmd(ipc .. " clipboard-clear"))

hl.bind(mainMod .. "+ e", hl.dsp.exec_cmd("emote"))

-- Notifications
hl.bind(mainMod .. "+ n", hl.dsp.exec_cmd(ipc .. " notification-clear-active"))
hl.bind(mainMod .. "+ SHIFT + n", hl.dsp.exec_cmd(ipc .. " notification-clear-history"))
hl.bind(mainMod .. "+ ALT + d", hl.dsp.exec_cmd(ipc .. " notification-dnd-toggle"))
hl.bind(mainMod .. "+ CTRL + n", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center notifications"))

-- TODO check if this works
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + d",   hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + SHIFT + d",   hl.dsp.exec_cmd("rofi -show run"))

-- Project selector
hl.bind(mainMod .. " + p",   hl.dsp.exec_cmd('dir=$(ls ~/Projects/ | rofi -dmenu -p "Choose project: ") && footclient sh -c "cd ~/Projects/$dir && tmux attach -t $dir || tmux new -s $dir"'))
-- Open notes
hl.bind(mainMod .. "+ SHIFT + p",   hl.dsp.exec_cmd('footclient sh -c "cd ~/Notes/ && tmux attach -t notes || tmux new -s notes $EDITOR"'))

hl.bind(mainMod .. " + s",   hl.dsp.exec_cmd('grim -g "$(slurp -d)" - | wl-copy'))
hl.bind(mainMod .. " + t",   hl.dsp.exec_cmd('grim -o eDP-1 - | wl-copy'))
hl.bind(mainMod .. " + r",   hl.dsp.exec_cmd('grim -o DP-2 - | wl-copy'))
hl.bind(mainMod .. " + t",   hl.dsp.exec_cmd('grim -o DP-1 - | wl-copy'))
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
            --middle_button_emulation = true,
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

hl.device({
    name = "synps/2-synaptics-touchpad",
    enabled = false,
})

hl.on("hyprland.start", function()
  hl.exec_cmd("emote")
  hl.exec_cmd("easyeffects")
  hl.exec_cmd("noctalia")
  hl.exec_cmd("systemctl --user start foot-server.service")
  hl.exec_cmd("nextcloud")
  hl.exec_cmd("playerctld")
end)

