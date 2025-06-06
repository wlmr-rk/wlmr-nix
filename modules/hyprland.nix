# hyprland.nix
{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      env = [
        "XCURSOR_THEME,Bibata-Original-Classic" # Matches the gtk.cursorTheme.name
        "XCURSOR_SIZE,24" # Matches the gtk.cursorTheme.size
      ];
      monitor = [
        "DP-2,1920x1080@144.00Hz,0x0,1,vrr,1"
        "HDMI-A-1,1920x1080@60,1920x0,1"
      ];

      workspace = [
        "1,monitor:DP-2,persistent:true"
        "2,monitor:DP-2,persistent:true"
        "3,monitor:HDMI-A-1,persistent:true"
        "4,monitor:HDMI-A-1,persistent:true"
      ];

      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 1;
        "col.active_border" = "rgba(bb9af7ff)"; # Tokyo Night purple
        "col.inactive_border" = "rgba(16161eff)"; # Near black
        layout = "dwindle";
        allow_tearing = false;
      };
      # Decoration settings for minimal dark theme
      decoration = {
        rounding = 0; # Sharp edges for dystopian feel
        blur = {
          enabled = true;
          size = 12;
          passes = 3;
          new_optimizations = true;
          vibrancy = 0.1696;
        };
      };
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 2, myBezier"
          "windowsOut, 1, 2, default, popin 80%"
          "border, 1, 5, default"
          "borderangle, 1, 4, default"
          "fade, 1, 2, default"
          "workspaces, 1, 2, default"
        ];
      };
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };
      misc = {
        vrr = 1;
        background_color = "0x000000";
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
      };
      exec-once = [
        "waybar & mako & udiskie &"
        "qbittorrent --no-splash &"
        "nohup wl-paste --watch notify-send 'クリップボード' '新しい内容がコピーされました' >/dev/null 2>&1 &"
        "clipse -listen"
      ];
      input = {
        accel_profile = "flat";
        numlock_by_default = true;
        touchpad = {
          natural_scroll = true;
        };
      };
      # Key bindings - Fixed Super_L binding
      bind = [
        ", mouse:275, exec, wtype -M alt -P Right -p alt"
        ", mouse:276, exec, wtype -M alt -P Left -p alt"
        "SUPER CTRL ALT, P, exec, poweroff"
        "SUPER, Q, exec, alacritty"
        "SUPER SHIFT, Q, exec, nvim"
        "SUPER SHIFT, W, killactive"
        "SUPER, S, exec, fuzzel-enhanced search"
        "SUPER, R, exec, fuzzel-enhanced run"
        "SUPER, A, exec, fuzzel-enhanced ai"
        "SUPER, M, exit"
        "SUPER, E, exec, nautilus"
        "SUPER, P, pseudo"
        "SUPER, F, fullscreen"
        "SUPER, Tab, cyclenext"
        # Clipse clipboard manager - SUPER + C - optimized for vertical layout
        "SUPER, C, exec, alacritty --class clipse -e 'clipse'"
        # Screenshots
        ''SUPER SHIFT, S, exec, grim -g "$(slurp)" ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png && wl-copy < ~/Pictures/screenshot_$(date +%Y%m%d_%H%M%S).png''
        # Movement
        "SUPER, H, movefocus, l"
        "SUPER, L, movefocus, r"
        "SUPER, K, movefocus, u"
        "SUPER, J, movefocus, d"
        # Workspaces
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        # Move windows to workspaces
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
      ];
      bindr = "SUPER, SUPER_L, exec, pkill fuzzel || fuzzel";
      bindm = "SUPER, mouse:272, movewindow";
      # Window rules for productivity and browser popups
      windowrulev2 = [
        # Clipse clipboard manager - optimized vertical layout for clipboard history
        "float,class:^(clipse)$"
        "size 700 900,class:^(clipse)$"
        "center,class:^(clipse)$"
        "stayfocused,class:^(clipse)$"
        "animation slide,class:^(clipse)$"

        "float,class:^(org.gnome.clocks)$"
        "center,class:^(org.gnome.clocks)$"
        "float,class:^(org.gnome.Calculator)$"
        "center,class:^(org.gnome.Calculator)$"
        # Anki floating
        "float,class:^(Anki)$"
        "size 1200 800,class:^(Anki)$"
        "center,class:^(Anki)$"
        # Browser popups as floating windows
        "float,title:^(Picture-in-Picture)$"
        "float,title:^(Firefox — Sharing Indicator)$"
        "float,title:^(DevTools)$"
        "float,class:^(firefox)$,title:^(Library)$"
        "float,class:^(firefox)$,title:^(Page Info)$"
        "float,class:^(firefox)$,title:^(Firefox Preferences)$"
        # Generic popup rules
        "float,class:^(.*)$,title:^(.*[Pp]opup.*)$"
        "float,class:^(.*)$,title:^(.*[Dd]ialog.*)$"
        "float,class:^(.*)$,title:^(.*[Pp]references.*)$"
        "float,class:^(.*)$,title:^(.*[Ss]ettings.*)$"
        # Network Manager GUI
        "float,class:^(nm-connection-editor)$"
        "size 1280 720,class:^(nm-connection-editor)$"
        "center,class:^(nm-connection-editor)$"
        # Audio GUI
        "float,class:^(pavucontrol)$"
        "size 1280 720,class:^(pavucontrol)$"
        "center,class:^(pavucontrol)$"
        # Nautilus
        "float,class:^(org.gnome.Nautilus)$"
        "size 1280 720,class:^(org.gnome.Nautilus)$"
        "center,class:^(org.gnome.Nautilus)$"
        # qBittorrent
        "float,class:^(org.qbittorrent.qBittorrent)$"
        "size 1280 720,class:^(org.qbittorrent.qBittorrent)$"
        "center,class:^(org.qbittorrent.qBittorrent)$"
      ];
    };
  };
  # Waybar configuration - Japanese Dark Theme
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        margin-top = 2;
        margin-left = 4;
        margin-right = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "bluetooth" "pulseaudio" "network" "battery" "tray" ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "壱"; # Japanese numeral 1
            "2" = "弐"; # Japanese numeral 2  
            "3" = "参"; # Japanese numeral 3
            "4" = "四"; # Japanese numeral 4
            "5" = "五"; # Japanese numeral 5
            default = "虚"; # Void/empty
          };
          persistent-workspaces = {
            "1" = [ ];
            "2" = [ ];
            "3" = [ ];
            "4" = [ ];
            "5" = [ ];
          };
        };
        "hyprland/window" = {
          format = "{class}";
          max-length = 1;
          separate-outputs = true;
          icon = true;
          icon-size = 16;
          rewrite = {
            "(.*)" = ""; # Hide all text, show only icon
          };
        };
        clock = {
          format = "時 {:%H:%M}"; # 時 = time
          format-alt = "日 {:%Y年%m月%d日 %H:%M}"; # Japanese date format
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
        cpu = {
          format = "{icon} {usage}%";
          interval = 2;
          format-icons = [ "󰾆" "󰾅" "󰓅" ];
          states = {
            warning = 70;
            critical = 90;
          };
        };
        memory = {
          format = "{icon} {percentage}%";
          interval = 2;
          format-icons = [ "󰍛" "󰍜" "󰍝" ];
          states = {
            warning = 70;
            critical = 90;
          };
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G";
        };
        bluetooth = {
          format = "󰂯";
          format-connected = "󰂱 {num_connections}";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          format-disabled = "󰂲";
          format-off = "󰂲";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "bluetoothctl power toggle";
        };
        battery = {
          format = "電 {capacity}%"; # 電 = electricity/power
          format-charging = "充 {capacity}%"; # 充 = charging
          format-plugged = "接 {capacity}%"; # 接 = connected
          format-critical = "危 {capacity}%"; # 危 = danger
          states = {
            warning = 30;
            critical = 15;
          };
        };
        network = {
          format-wifi = "{icon}";
          format-ethernet = "󰈀";
          format-disconnected = "󰈂";
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          tooltip-format-wifi = "WiFi: {essid} ({signalStrength}%)\n{ipaddr}";
          tooltip-format-ethernet = "Ethernet: {ipaddr}";
          tooltip-format-disconnected = "Disconnected";
        };
        pulseaudio = {
          format = "音 {volume}%"; # 音 = sound
          format-muted = "静 消音"; # 静 = silence, 消音 = muted
          on-click = "pavucontrol";
        };
        tray = {
          icon-size = 16;
          spacing = 8;
        };
      };
    };
    style = ''
      * {
        font-family: "JetBrains Mono Nerd Font", "Noto Sans CJK JP";
        font-size: 12px;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
        color: #c0caf5; /* TokyoNight foreground */
      }
      
      window#waybar {
        background: rgba(0, 0, 0, 0.95); /* Pure black background */
        color: #c0caf5; /* TokyoNight foreground */
        border: 1px solid #15161e; /* TokyoNight dark border */
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.9);
        
      }
      
      #workspaces {
        background: rgba(0, 0, 0, 0.4); /* Pure black with transparency */
        margin: 4px 4px;
        padding: 0 8px;
        border: 1px solid #15161e; /* TokyoNight black border */
      }
      
      #workspaces button {
        padding: 4px 12px;
        color: #565f89; /* TokyoNight comment */
        background: transparent;
        transition: all 0.2s ease;
        font-weight: bold;
        border: 1px solid transparent;
      }
      
      #workspaces button.active {
        color: #bb9af7; /* TokyoNight purple */
        background: rgba(187, 154, 247, 0.1);
        border: 1px solid #bb9af7;
      }
      
      #workspaces button:hover {
        color: #7aa2f7; /* TokyoNight blue */
        background: rgba(122, 162, 247, 0.1);
      }
      
      #window {
        color: #808080; 
        background: rgba(0, 0, 0, 0.3); 
        padding: 4px 8px;
        margin: 4px;
        border: 1px solid #15161e;
        min-width: 24px;
      }
      
      #clock {
        color: #bb9af7;
        background: rgba(0, 0, 0, 0.4);
        padding: 4px 16px;
        margin: 4px;
        font-weight: bold;
        border: 1px solid #414868;
      }
      
      #cpu,
      #memory,
      #bluetooth,
      #battery,
      #network,
      #pulseaudio {
        color: #9ece6a; 
        background: rgba(0, 0, 0, 0.3);
        padding: 4px 12px;
        margin: 4px 2px;
        border: 1px solid #15161e;
      }
      
      #cpu {
        color: #7aa2f7;
      }
      
      #memory {
        color: #bb9af7;
      }
      
      #bluetooth {
        color: #7dcfff; /* TokyoNight cyan for Bluetooth */
      }
      
      #bluetooth.disabled,
      #bluetooth.off {
        color: #565f89; /* TokyoNight comment for disabled */
        background: rgba(86, 95, 137, 0.1);
      }
      
      #cpu.warning,
      #memory.warning {
        color: #e0af68; /* TokyoNight yellow */
        background: rgba(224, 175, 104, 0.1);
      }
      
      #cpu.critical,
      #memory.critical {
        color: #f7768e; /* TokyoNight red */
        background: rgba(247, 118, 142, 0.1);
        animation: blink 1s ease-in-out infinite alternate;
      }
      
      #battery.warning {
        color: #e0af68; /* TokyoNight yellow */
        background: rgba(224, 175, 104, 0.1);
      }
      
      #battery.critical {
        color: #f7768e; /* TokyoNight red */
        background: rgba(247, 118, 142, 0.1);
        animation: blink 1s ease-in-out infinite alternate;
      }
      
      #network.disconnected {
        color: #f7768e; /* TokyoNight red */
        background: rgba(247, 118, 142, 0.1);
      }
      
      #pulseaudio.muted {
        color: #565f89; /* TokyoNight comment */
        background: rgba(86, 95, 137, 0.1);
      }
      
      #tray {
        background: rgba(0, 0, 0, 0.3); /* Pure black with transparency */
        padding: 4px 8px;
        margin: 4px;
        border: 1px solid #15161e;
      }
      
      @keyframes blink {
        to {
          background-color: rgba(247, 118, 142, 0.3);
          color: #ffffff;
        }
      }
      
      tooltip {
        background: rgba(0, 0, 0, 0.95); /* Pure black background */
        color: #c0caf5; /* TokyoNight foreground */
        border: 1px solid #bb9af7; /* TokyoNight purple border */
        border-radius: 0;
        font-family: "JetBrains Mono Nerd Font";
      }
      
      #workspaces button.urgent {
        color: #f7768e; /* TokyoNight red */
        background: rgba(247, 118, 142, 0.2);
        border: 1px solid #f7768e;
      }
      
      #cpu:hover,
      #memory:hover,
      #bluetooth:hover,
      #battery:hover,
      #network:hover,
      #pulseaudio:hover,
      #clock:hover {
        border: 1px solid #bb9af7;
        background: rgba(187, 154, 247, 0.05);
      }
    '';
  };
  # Notification daemon
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrains Mono Nerd Font 11";
      background-color = "#000000";
      text-color = "#c0caf5";
      border-color = "#bb9af7";
      default-timeout = 3000;
      max-visible = 3;
      layer = "overlay";
      anchor = "top-right";
      margin = "10";
      padding = "15";
      border-size = 2;
      width = 400;
      height = 150;
      max-history = 100;
    };
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.catppuccin-papirus-folders.override {
        flavor = "macchiato";
        accent = "lavender";
      };
      name = "Papirus-Dark";
    };
    theme = {
      name = "catppuccin-macchiato-mauve-compact";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "macchiato";
        size = "compact";
      };
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };
  home.packages = with pkgs; [
    clipse
    grim
    slurp
    wl-clipboard
    libnotify #allows notify-send
    mako

    file
  ];
}
