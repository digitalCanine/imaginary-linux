#!/bin/bash
# BSPWM Window Manager Setup Script

echo "Configuring BSPWM..."

# Create config directories
mkdir -p "$USER_HOME/.config/bspwm"
mkdir -p "$USER_HOME/.config/sxhkd"
mkdir -p "$USER_HOME/.config/polybar"
mkdir -p "$USER_HOME/.config/picom"
mkdir -p "$USER_HOME/.config/rofi"
mkdir -p "$USER_HOME/.config/dunst"

# If user wants custom rice, install it
if [ "$INSTALL_RICE" = "true" ]; then
  echo "Installing Imaginary BSPWM rice from GitHub..."

  RICE_REPO="https://github.com/schizopup/bspwm-rice" # Update with your actual repo

  cd /tmp
  if git clone "$RICE_REPO" imaginary-rice 2>/dev/null; then
    # Copy configs
    if [ -d "imaginary-rice/.config" ]; then
      cp -r imaginary-rice/.config/* "$USER_HOME/.config/"
      echo "Configs installed from rice"
    fi

    # Copy themes if they exist
    if [ -d "imaginary-rice/.themes" ]; then
      mkdir -p "$USER_HOME/.themes"
      cp -r imaginary-rice/.themes/* "$USER_HOME/.themes/"
      echo "Themes installed from rice"
    fi

    # Copy local files if they exist
    if [ -d "imaginary-rice/.local" ]; then
      mkdir -p "$USER_HOME/.local"
      cp -r imaginary-rice/.local/* "$USER_HOME/.local/"
      echo "Local files installed from rice"
    fi

    # Cleanup
    rm -rf /tmp/imaginary-rice

    echo "Imaginary BSPWM rice installed successfully!"
  else
    echo "Warning: Could not clone rice repository, using default config"
    INSTALL_RICE="false"
  fi
fi

# If not using rice or rice failed, create basic config
if [ "$INSTALL_RICE" != "true" ]; then
  echo "Setting up default BSPWM configuration..."

  # Basic BSPWM config
  cat >"$USER_HOME/.config/bspwm/bspwmrc" <<'EOF'
#!/bin/sh

# Autostart
sxhkd &
picom -b &
nitrogen --restore &
polybar main &
dunst &
nm-applet &

# BSPWM configuration
bspc monitor -d I II III IV V VI VII VIII IX X

bspc config border_width         2
bspc config window_gap          12
bspc config split_ratio          0.52
bspc config borderless_monocle   true
bspc config gapless_monocle      true

# Colors
bspc config normal_border_color   "#44475a"
bspc config active_border_color   "#bd93f9"
bspc config focused_border_color  "#ff79c6"
bspc config presel_feedback_color "#6272a4"

# Rules
bspc rule -a Gimp desktop='^8' state=floating follow=on
bspc rule -a Firefox desktop='^2'
bspc rule -a mplayer2 state=floating
bspc rule -a Kupfer.py focus=on
bspc rule -a Screenkey manage=off
EOF

  chmod +x "$USER_HOME/.config/bspwm/bspwmrc"

  # Basic SXHKD config
  cat >"$USER_HOME/.config/sxhkd/sxhkdrc" <<'EOF'
#
# wm independent hotkeys
#

# terminal emulator
super + Return
	kitty

# program launcher
super + d
	rofi -show drun

# make sxhkd reload its configuration files:
super + Escape
	pkill -USR1 -x sxhkd

#
# bspwm hotkeys
#

# quit/restart bspwm
super + alt + {q,r}
	bspc {quit,wm -r}

# close and kill
super + {_,shift + }q
	bspc node -{c,k}

# alternate between the tiled and monocle layout
super + m
	bspc desktop -l next

# send the newest marked node to the newest preselected node
super + y
	bspc node newest.marked.local -n newest.!automatic.local

# swap the current node and the biggest window
super + g
	bspc node -s biggest.window

#
# state/flags
#

# set the window state
super + {t,shift + t,s,f}
	bspc node -t {tiled,pseudo_tiled,floating,fullscreen}

# set the node flags
super + ctrl + {m,x,y,z}
	bspc node -g {marked,locked,sticky,private}

#
# focus/swap
#

# focus the node in the given direction
super + {_,shift + }{h,j,k,l}
	bspc node -{f,s} {west,south,north,east}

# focus the node for the given path jump
super + {p,b,comma,period}
	bspc node -f @{parent,brother,first,second}

# focus the next/previous window in the current desktop
super + {_,shift + }c
	bspc node -f {next,prev}.local.!hidden.window

# focus the next/previous desktop in the current monitor
super + bracket{left,right}
	bspc desktop -f {prev,next}.local

# focus the last node/desktop
super + {grave,Tab}
	bspc {node,desktop} -f last

# focus the older or newer node in the focus history
super + {o,i}
	bspc wm -h off; \
	bspc node {older,newer} -f; \
	bspc wm -h on

# focus or send to the given desktop
super + {_,shift + }{1-9,0}
	bspc {desktop -f,node -d} '^{1-9,10}'

#
# preselect
#

# preselect the direction
super + ctrl + {h,j,k,l}
	bspc node -p {west,south,north,east}

# preselect the ratio
super + ctrl + {1-9}
	bspc node -o 0.{1-9}

# cancel the preselection for the focused node
super + ctrl + space
	bspc node -p cancel

# cancel the preselection for the focused desktop
super + ctrl + shift + space
	bspc query -N -d | xargs -I id -n 1 bspc node id -p cancel

#
# move/resize
#

# expand a window by moving one of its side outward
super + alt + {h,j,k,l}
	bspc node -z {left -20 0,bottom 0 20,top 0 -20,right 20 0}

# contract a window by moving one of its side inward
super + alt + shift + {h,j,k,l}
	bspc node -z {right -20 0,top 0 20,bottom 0 -20,left 20 0}

# move a floating window
super + {Left,Down,Up,Right}
	bspc node -v {-20 0,0 20,0 -20,20 0}

# Screenshot
Print
	maim -s | xclip -selection clipboard -t image/png

# Lock screen
super + shift + x
	betterlockscreen -l dim
EOF

  # Basic Polybar config
  cat >"$USER_HOME/.config/polybar/config.ini" <<'EOF'
[colors]
background = #1e1e2e
foreground = #cdd6f4
primary = #8b45ff
secondary = #89dceb
alert = #f38ba8

[bar/main]
width = 100%
height = 24pt
background = ${colors.background}
foreground = ${colors.foreground}
line-size = 3pt
border-size = 0
padding-left = 1
padding-right = 1
module-margin = 1
separator = |
separator-foreground = ${colors.primary}
font-0 = "DejaVu Sans Mono:size=10;2"
modules-left = xworkspaces
modules-center = date
modules-right = pulseaudio memory cpu wlan battery
cursor-click = pointer
cursor-scroll = ns-resize
enable-ipc = true

[module/xworkspaces]
type = internal/xworkspaces
label-active = %name%
label-active-background = ${colors.primary}
label-active-padding = 1
label-occupied = %name%
label-occupied-padding = 1
label-urgent = %name%
label-urgent-background = ${colors.alert}
label-urgent-padding = 1
label-empty = %name%
label-empty-foreground = ${colors.foreground}
label-empty-padding = 1

[module/pulseaudio]
type = internal/pulseaudio
format-volume = <label-volume>
label-volume = VOL %percentage%%
label-muted = muted
label-muted-foreground = ${colors.alert}

[module/memory]
type = internal/memory
interval = 2
format = <label>
label = RAM %percentage_used:2%%

[module/cpu]
type = internal/cpu
interval = 2
format = <label>
label = CPU %percentage:2%%

[module/date]
type = internal/date
interval = 1
date = %Y-%m-%d %H:%M
label = %date%

[module/wlan]
type = internal/network
interface-type = wireless
interval = 3.0
format-connected = <label-connected>
label-connected = %essid%

[module/battery]
type = internal/battery
battery = BAT0
adapter = AC
format-charging = <label-charging>
format-discharging = <label-discharging>
label-charging = CHG %percentage%%
label-discharging = BAT %percentage%%
EOF

  # Basic Picom config
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

# Transparency
inactive-opacity = 0.95;

# Backend
backend = "glx";
vsync = true;
EOF

  # Basic Rofi config
  mkdir -p "$USER_HOME/.config/rofi"
  cat >"$USER_HOME/.config/rofi/config.rasi" <<'EOF'
configuration {
    modi: "drun,run,window";
    show-icons: true;
    terminal: "kitty";
    display-drun: "Apps";
    display-run: "Run";
    display-window: "Window";
}

@theme "/usr/share/rofi/themes/Arc-Dark.rasi"
EOF

  echo "Default BSPWM configuration created"
fi

# Set proper permissions
chown -R $USERNAME:$USERNAME "$USER_HOME/.config"
[ -d "$USER_HOME/.themes" ] && chown -R $USERNAME:$USERNAME "$USER_HOME/.themes"
[ -d "$USER_HOME/.local" ] && chown -R $USERNAME:$USERNAME "$USER_HOME/.local"

# Make bspwmrc executable
chmod +x "$USER_HOME/.config/bspwm/bspwmrc"

# Enable display manager
systemctl enable ly

# Enable NetworkManager
systemctl enable NetworkManager

echo "BSPWM setup complete!"
if [ "$INSTALL_RICE" = "true" ]; then
  echo "Custom Imaginary rice has been installed!"
else
  echo "Default configuration installed. Keybindings:"
  echo "  Super+Enter: Open terminal"
  echo "  Super+D: Application launcher"
  echo "  Super+Q: Close window"
  echo "  Super+[1-0]: Switch workspaces"
fi
