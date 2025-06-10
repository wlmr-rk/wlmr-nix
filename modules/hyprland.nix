# hyprland.nix
{ pkgs, ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = builtins.readFile ../config/hyprland.conf;
    xwayland.enable = true;
  };
  programs.waybar = {
    enable = true;
    style = builtins.readFile ../config/waybar/style.css;
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
  };
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
