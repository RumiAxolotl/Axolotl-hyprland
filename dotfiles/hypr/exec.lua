-- ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
-- ┃       Autostart (exec-once)           ┃
-- ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

hl.on("hyprland.start", function()
    -- Clipboard
    hl.exec_cmd("wl-clipboard-history -t")

    -- XDG & D-Bus
    hl.exec_cmd("~/.config/hypr/xdg-portal-hyprland")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- Authentication
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    -- Notifications
    hl.exec_cmd("systemctl --user start dunst.service")

    -- Input method
    hl.exec_cmd("fcitx5 -d")

    -- Night light
    hl.exec_cmd("wlsunset -S 6:00 -s 18:00 -t 4500 -T 5500 -d 1800")

    -- Idle daemon
    hl.exec_cmd("hypridle -q")

    -- Shell & UI
    hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("~/.config/waybar/scripts/touchpad")
    hl.exec_cmd("rog-control-center")
    hl.exec_cmd('nwg-dock-hyprland -r -p bottom -a center -mb 15 -ml 15 -mr 15 -i 36 -c "rofi -show drun"')

    -- Noctalia Visual Editor watchdog
    hl.exec_cmd("/home/rumi/.cache/noctalia/HVE/hve_watchdog.sh")
end)
