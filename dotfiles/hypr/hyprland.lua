-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃                    Hyprland Configuration                     ┃
-- ┃               Migrated from hyprlang to Lua                   ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

-- Load color palette
local colors = require("style")

-- Load modules
require("exec")
require("keybind")
require("nvidia")


-----------------------
---- ENVIRONMENT ------
-----------------------

hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")


------------------
---- MONITORS ----
------------------

-- monitor=DP-1,1920x1080@60,0x0,1  (disabled)
hl.monitor({ output = "eDP-1",    mode = "1920x1080@144", position = "0x1080", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@75",  position = "1920x0", scale = 1, transform = 1 })


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        float_switch_override_focus = 1,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- Touchpad device
hl.device({
    name = "asup1205:00-093a:2008-touchpad",
    enabled = true,
})


-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 8,
        border_size = 2,

        -- Monochrome borders (defaults, may be overridden by Noctalia)
        col = {
            active_border   = "rgba(" .. colors.text .. "ff)",
            inactive_border = "rgba(" .. colors.surface0 .. "ff)",
        },

        layout           = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding         = 8,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Blur disabled for performance and clean look
        blur = {
            enabled = false,
        },
    },

    animations = {
        enabled = true,
    },
})


-----------------------
---- ANIMATIONS -------
-----------------------

-- Fast, snappy, linear bezier curve
hl.curve("fastSnappy", { type = "bezier", points = { {0.1, 1.0}, {0.1, 1.0} } })

hl.animation({ leaf = "windows",    enabled = true,  speed = 3, bezier = "fastSnappy", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true,  speed = 3, bezier = "fastSnappy", style = "slide" })
hl.animation({ leaf = "border",     enabled = false })
hl.animation({ leaf = "fade",       enabled = true,  speed = 2, bezier = "fastSnappy" })
hl.animation({ leaf = "workspaces", enabled = true,  speed = 3, bezier = "fastSnappy" })


-----------------------
---- LAYOUTS ----------
-----------------------

hl.config({
    dwindle = {
        preserve_split = true,
        smart_resizing = true,
    },
})


----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        mouse_move_enables_dpms  = true,
        enable_swallow           = true,
        swallow_regex            = "^(kitty)$",
    },
})


-----------------------------------
---- NOCTALIA VISUAL EDITOR -------
-----------------------------------
-- Noctalia color overrides and overlay are loaded from legacy .conf files.
-- The noctalia-colors.conf sets border colors and group colors.
-- The overlay.conf applies visual editor effects.
-- These are loaded via hyprctl at startup since hl.source() is not available.

hl.on("config.reloaded", function()
    -- Apply Noctalia colors on each reload
    os.execute("hyprctl source /home/rumi/.config/hypr/noctalia/noctalia-colors.conf &")
    os.execute("hyprctl source /home/rumi/.cache/noctalia/HVE/overlay.conf &")
end)

-- Also apply on initial load
os.execute("hyprctl source /home/rumi/.config/hypr/noctalia/noctalia-colors.conf &")
os.execute("hyprctl source /home/rumi/.cache/noctalia/HVE/overlay.conf &")
