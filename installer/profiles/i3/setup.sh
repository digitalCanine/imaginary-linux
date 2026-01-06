#!/bin/bash
# i3 Window Manager Setup Script

echo "Configuring i3..."

# Create config directories
mkdir -p "$USER_HOME/.config/i3"
mkdir -p "$USER_HOME/.config/i3status"
mkdir -p "$USER_HOME/.config/picom"
mkdir -p "$USER_HOME/.config/dunst"

# Generate default i3 config
cat >"$USER_HOME/.config/i3/config" <<'EOF'
# i3 config file (v4)

# Mod key (Mod1=Alt, Mod4=Super/Windows)
set $mod Mod4

# Font for window titles
font pango:DejaVu Sans Mono 8

# Use Mouse+$mod to drag floating windows
floating_modifier $mod

# Start a terminal
bindsym $mod+Return exec kitty

# Kill focused window
bindsym $mod+Shift+q kill

# Start rofi (program launcher)
bindsym $mod+d exec --no-startup-id rofi -show drun

# Change focus
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move focused window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Split in horizontal orientation
bindsym $mod+b split h

# Split in vertical orientation
bindsym $mod+v split v

# Enter fullscreen mode
bindsym $mod+f fullscreen toggle

# Change container layout (stacked, tabbed, toggle split)
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

# Toggle tiling / floating
bindsym $mod+Shift+space floating toggle

# Change focus between tiling / floating windows
bindsym $mod+space focus mode_toggle

# Define names for workspaces
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

# Switch to workspace
bindsym $mod+1 workspace number $ws1
bindsym $mod+2 workspace number $ws2
bindsym $mod+3 workspace number $ws3
bindsym $mod+4 workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

# Move focused container to workspace
bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

# Reload the configuration file
bindsym $mod+Shift+c reload

# Restart i3 inplace
bindsym $mod+Shift+r restart

# Exit i3
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'"

# Resize mode
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"

# Start i3bar
bar {
    status_command i3status
    position top
}

# Autostart applications
exec --no-startup-id picom -b
exec --no-startup-id nitrogen --restore
exec --no-startup-id dunst
exec --no-startup-id nm-applet
EOF

# Basic i3status config
cat >"$USER_HOME/.config/i3status/config" <<'EOF'
general {
    colors = true
    interval = 5
}

order += "wireless _first_"
order += "ethernet _first_"
order += "battery all"
order += "disk /"
order += "load"
order += "memory"
order += "tztime local"

wireless _first_ {
    format_up = "W: (%quality at %essid) %ip"
    format_down = "W: down"
}

ethernet _first_ {
    format_up = "E: %ip (%speed)"
    format_down = "E: down"
}

battery all {
    format = "%status %percentage %remaining"
    status_chr = "⚡"
    status_bat = "🔋"
    status_full = "☻"
}

disk "/" {
    format = "💾 %avail"
}

load {
    format = "⚙ %1min"
}

memory {
    format = "💻 %used"
    threshold_degraded = "10%"
}

tztime local {
    format = "📅 %Y-%m-%d %H:%M"
}
EOF

# Basic picom config
cat >"$USER_HOME/.config/picom/picom.conf" <<'EOF'
# Shadows
shadow = true;
shadow-radius = 7;
shadow-opacity = 0.7;
shadow-offset-x = -7;
shadow-offset-y = -7;

# Fading
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
fade-delta = 5;

# Transparency
inactive-opacity = 0.95;
frame-opacity = 0.9;

# Backend
backend = "glx";
vsync = true;
EOF

# Dunst notification config
mkdir -p "$USER_HOME/.config/dunst"
cp /usr/share/dunst/dunstrc "$USER_HOME/.config/dunst/" 2>/dev/null || true

# Set ownership
chown -R $USERNAME:$USERNAME "$USER_HOME/.config"

# Enable display manager
systemctl enable ly

# Enable NetworkManager
systemctl enable NetworkManager

echo "i3 setup complete!"
echo "Default keybindings:"
echo "  Mod+Enter: Open terminal"
echo "  Mod+d: Application launcher"
echo "  Mod+Shift+q: Close window"
echo "  Mod+[1-0]: Switch workspaces"
