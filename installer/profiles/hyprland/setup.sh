#!/bin/bash
# Hyprland Wayland Compositor Setup Script

echo "Configuring Hyprland..."

# Create config directories
mkdir -p "$USER_HOME/.config/hypr"
mkdir -p "$USER_HOME/.config/waybar"
mkdir -p "$USER_HOME/.config/wofi"

# Generate Hyprland config
cat >"$USER_HOME/.config/hypr/hyprland.conf" <<'EOF'
# Hyprland configuration

# Monitor configuration
monitor=,preferred,auto,1

# Execute apps at launch
exec-once = waybar
exec-once = dunst
exec-once = swaybg -i /usr/share/backgrounds/default.png -m fill
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1

# Environment variables
env = XCURSOR_SIZE,24
env = QT_QPA_PLATFORMTHEME,qt5ct

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = false
    }
    sensitivity = 0
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(8b45ffee)
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = true
    shadow_range = 4
    shadow_render_power = 3
    col.shadow = rgba(1a1a1aee)
}

# Animations
animations {
    enabled = true
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Layouts
dwindle {
    pseudotile = true
    preserve_split = true
}

# Key bindings
$mainMod = SUPER

# Applications
bind = $mainMod, Return, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, D, exec, wofi --show drun
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,
bind = $mainMod, F, fullscreen,

# Move focus with mainMod + arrow keys
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move active window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Scroll through workspaces
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Move/resize windows
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Screenshots
bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
bind = SHIFT, Print, exec, grim - | wl-copy
EOF

# Waybar config
cat >"$USER_HOME/.config/waybar/config" <<'EOF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces", "hyprland/window"],
    "modules-center": ["clock"],
    "modules-right": ["pulseaudio", "network", "battery", "tray"],
    
    "hyprland/workspaces": {
        "format": "{name}",
        "on-click": "activate"
    },
    
    "clock": {
        "format": "{:%Y-%m-%d %H:%M}",
        "tooltip": false
    },
    
    "battery": {
        "format": "{capacity}% {icon}",
        "format-icons": ["", "", "", "", ""]
    },
    
    "network": {
        "format-wifi": "{essid} ",
        "format-ethernet": "{ifname} ",
        "format-disconnected": "Disconnected ⚠",
        "tooltip": false
    },
    
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "",
        "format-icons": {
            "default": ["", "", ""]
        },
        "on-click": "pavucontrol"
    }
}
EOF

# Waybar style
cat >"$USER_HOME/.config/waybar/style.css" <<'EOF'
* {
    border: none;
    border-radius: 0;
    font-family: "DejaVu Sans Mono";
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: rgba(27, 27, 27, 0.9);
    color: white;
}

#workspaces button {
    padding: 0 5px;
    background: transparent;
    color: white;
}

#workspaces button.active {
    background: rgba(139, 69, 255, 0.5);
}

#clock, #battery, #network, #pulseaudio {
    padding: 0 10px;
}
EOF

# Wofi config
cat >"$USER_HOME/.config/wofi/config" <<'EOF'
width=600
height=400
location=center
show=drun
prompt=Search...
filter_rate=100
allow_markup=true
no_actions=true
halign=fill
orientation=vertical
content_halign=fill
insensitive=true
allow_images=true
image_size=40
EOF

# Set ownership
chown -R $USERNAME:$USERNAME "$USER_HOME/.config"

# Enable display manager
systemctl enable ly

# Enable NetworkManager
systemctl enable NetworkManager

echo "Hyprland setup complete!"
echo "Default keybindings:"
echo "  Super+Enter: Open terminal"
echo "  Super+D: Application launcher"
echo "  Super+Q: Close window"
echo "  Super+[1-0]: Switch workspaces"
