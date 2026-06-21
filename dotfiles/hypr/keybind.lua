-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃            Keybindings                ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
local mainMod = "SUPER"
local SCRIPT = "~/.config/hypr/scripts"
local ipc = "noctalia msg"

-- ┌──────────────────────────────────────┐
-- │         Application Launchers        │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + BackSpace", hl.dsp.exec_cmd("~/.config/hypr/keybind"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("xdg-open https://rumiaxolotl.github.io/newtab/"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd('code'))
hl.bind(mainMod .. " + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("killall noctalia || noctalia"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("killall spotify || spotify"))

-- ┌──────────────────────────────────────┐
-- │      Brightness & Volume (FN)        │
-- └──────────────────────────────────────┘

-- Brightness (repeat)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. " brightness-down"), {
    repeating = true
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. " brightness-up"), {
    repeating = true
})

-- Volume (locked + repeat)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. " volume-up"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. " volume-down"), {
    locked = true,
    repeating = true
})

-- Mic mute (repeat)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(SCRIPT .. "/volume --toggle-mic"), {
    repeating = true
})

-- Speaker mute (locked + repeat)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. " volume-mute"), {
    locked = true,
    repeating = true
})

-- Media controls (locked + repeat)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
    locked = true,
    repeating = true
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
    locked = true,
    repeating = true
})

-- Touchpad toggle (locked)
hl.bind("CTRL + " .. mainMod .. " + T", hl.dsp.exec_cmd(SCRIPT .. "/touchpad"), {
    locked = true
})

-- Audio loopback
hl.bind("CTRL + ALT + M", hl.dsp.exec_cmd("pactl load-module module-loopback latency_msec=10"), {
    repeating = true
})
hl.bind("CTRL + ALT + N", hl.dsp.exec_cmd("pactl unload-module module-loopback"), {
    repeating = true
})

-- ┌──────────────────────────────────────┐
-- │           Screenshots                │
-- └──────────────────────────────────────┘

local screenshotarea =
    [[hyprctl keyword animation "fadeOut,0,0,default"; grimblast --notify copysave area $(xdg-user-dir PICTURES)/Screenshots/$(date +'%d-%m-%Y+%H:%M:%S.png'); hyprctl keyword animation "fadeOut,1,4,default"]]

hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(screenshotarea), {
    locked = true
})

hl.bind("Print", hl.dsp.exec_cmd(
    [[grimblast --notify --cursor copysave screen $(xdg-user-dir PICTURES)/Screenshots/$(date +'%d-%m-%Y+%H:%M:%S.png')]]),
    {
        locked = true
    })

hl.bind("ALT + Print", hl.dsp.exec_cmd(
    [[grimblast --notify --cursor copysave active $(xdg-user-dir PICTURES)/Screenshots/$(date +'%d-%m-%Y+%H:%M:%S.png')]]),
    {
        locked = true
    })

hl.bind("CTRL + Print", hl.dsp.exec_cmd(
    [[grimblast --notify --cursor copysave output $(xdg-user-dir PICTURES)/Screenshots/$(date +'%d-%m-%Y+%H:%M:%S.png')]]),
    {
        locked = true
    })

-- OCR screenshot (English + Vietnamese)
hl.bind(mainMod .. " + SHIFT + T",
    hl.dsp.exec_cmd([[grimblast save area - | tesseract stdin stdout -l eng+vie | wl-copy]]), {
        locked = true
    })

-- ┌──────────────────────────────────────┐
-- │          Misc Utilities              │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprpicker -a -n"))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.exec_cmd("hyprctl kill"))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("killall rofi || rofi -show drun"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("killall rofi || rofi -show emoji"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. " settings-toggle"))
hl.bind(mainMod .. " + SHIFT + Escape", hl.dsp.exit())
hl.bind("CTRL + ALT + Delete", hl.dsp.exec_cmd("killall wlogout || wlogout --protocol layer-shell -b 5 -T 400 -B 400"),
    {
        repeating = true
    })

-- ┌──────────────────────────────────────┐
-- │        Window Management             │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + CTRL+ Space", hl.dsp.exec_cmd(ipc .. " panel-toggle launcher"))
hl.bind(mainMod .. "+ CTRL + S", hl.dsp.exec_cmd(ipc .. " panel-toggle control-center"))
hl.bind(mainMod .. " + Space", hl.dsp.window.float({
    action = "toggle"
}))
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))

-- ┌──────────────────────────────────────┐
-- │            Focus                     │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + left", hl.dsp.focus({
    direction = "left"
}))
hl.bind(mainMod .. " + right", hl.dsp.focus({
    direction = "right"
}))
hl.bind(mainMod .. " + up", hl.dsp.focus({
    direction = "up"
}))
hl.bind(mainMod .. " + down", hl.dsp.focus({
    direction = "down"
}))

-- ┌──────────────────────────────────────┐
-- │         Move Windows                 │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({
    direction = "left"
}))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({
    direction = "right"
}))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({
    direction = "up"
}))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({
    direction = "down"
}))

-- ┌──────────────────────────────────────┐
-- │         Resize Windows               │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + CTRL + left", hl.dsp.exec_cmd("hyprctl dispatch resizeactive -20 0"))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 20 0"))
hl.bind(mainMod .. " + CTRL + up", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -20"))
hl.bind(mainMod .. " + CTRL + down", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 20"))

-- ┌──────────────────────────────────────┐
-- │      Workspace Switching             │
-- └──────────────────────────────────────┘

-- Workspaces 1–10 (SUPER + 0-9)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({
        workspace = i
    }))
end

-- Workspaces 11–20 (SUPER + ALT + 0-9)
for i = 11, 20 do
    local key = (i - 10) % 10
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.focus({
        workspace = i
    }))
end

-- Workspace scroll (TAB)
hl.bind(mainMod .. " + TAB", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind("CTRL + " .. mainMod .. " + TAB", hl.dsp.focus({
    workspace = "e-1"
}))

-- ┌──────────────────────────────────────┐
-- │    Move Window to Workspace          │
-- └──────────────────────────────────────┘

-- Move to Workspaces 1–10 (SUPER + SHIFT + 0-9)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({
        workspace = i
    }))
end

-- Move to Workspaces 11–20 (SUPER + ALT + SHIFT + 0-9)
for i = 11, 20 do
    local key = (i - 10) % 10
    hl.bind(mainMod .. " + ALT + SHIFT + " .. key, hl.dsp.window.move({
        workspace = i
    }))
end

-- ┌──────────────────────────────────────┐
-- │         Mouse Bindings               │
-- └──────────────────────────────────────┘

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
    mouse = true
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
    mouse = true
})
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({
    workspace = "e+1"
}))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({
    workspace = "e-1"
}))
