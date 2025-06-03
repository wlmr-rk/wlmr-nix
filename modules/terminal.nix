# terminal.nix
{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    functions = { };
    shellAliases = {
      ll = "eza -la --icons";
      la = "eza -la --icons";
      ls = "eza --icons";
      tree = "eza --tree --icons";
      cat = "bat";
      find = "fd";
      grep = "rg";
      nixconf = "nvim ~/NixOS/c.nix";
      nixhome = "nvim ~/NixOS/h.nix";
      nixapp = "nvim ~/NixOS/modules/apps.nix";
      nixhypr = "nvim ~/NixOS/modules/hyprland.nix";
      nixterm = "nvim ~/NixOS/modules/terminal.nix";
    };
    shellInit = ''
      set -x lc_all en_us.utf-8
      set -g fish_greeting ""
      if command -v zoxide >/dev/null
        zoxide init fish | source
      end
    '';
  };

  programs.alacritty =
    {
      enable = true;
      settings = {
        env = {
          term = "xterm-256color";
        };
        window = {
          padding = { x = 20; y = 12; };
          opacity = 0.92;
          blur = true;
          decorations = "buttonless";
          startup_mode = "windowed";
          title = " ターミナル";
        };
        scrolling = {
          history = 50000;
          multiplier = 3;
        };
        font = {
          normal = {
            family = "jetbrains mono nerd font";
            style = "regular";
          };
          bold = {
            family = "jetbrains mono nerd font";
            style = "bold";
          };
          italic = {
            family = "jetbrains mono nerd font";
            style = "italic";
          };
          bold_italic = {
            family = "jetbrains mono nerd font";
            style = "bold italic";
          };
          size = 11;
          offset = { x = 0; y = 1; };
        };

        colors = {
          primary = {
            background = "0x000000";
            foreground = "0xc0caf5";
            dim_foreground = "0xa9b1d6";
          };
          cursor = {
            text = "0x000000";
            cursor = "0xc0caf5";
          };
          vi_mode_cursor = {
            text = "0x000000";
            cursor = "0x7aa2f7";
          };
          selection = {
            text = "0xc0caf5";
            background = "0x33467c";
          };
          search = {
            matches = {
              foreground = "0x000000";
              background = "0xff9e64";
            };
            focused_match = {
              foreground = "0x000000";
              background = "0xe0af68";
            };
          };
          normal = {
            black = "0x15161e";
            red = "0xf7768e";
            green = "0x9ece6a";
            yellow = "0xe0af68";
            blue = "0x7aa2f7";
            magenta = "0xbb9af7";
            cyan = "0x7dcfff";
            white = "0xa9b1d6";
          };
          bright = {
            black = "0x414868";
            red = "0xf7768e";
            green = "0x9ece6a";
            yellow = "0xe0af68";
            blue = "0x7aa2f7";
            magenta = "0xbb9af7";
            cyan = "0x7dcfff";
            white = "0xc0caf5";
          };
        };
        bell = {
          animation = "easeoutexpo";
          duration = 100;
          color = "0xff6b6b";
        };
        keyboard.bindings = [
          { key = "v"; mods = "control|shift"; action = "paste"; }
          { key = "c"; mods = "control|shift"; action = "copy"; }
          { key = "Equals"; mods = "control"; action = "increasefontsize"; } # Changed from "plus"
          { key = "Minus"; mods = "control"; action = "decreasefontsize"; } # Changed from "minus" 
          { key = "Key0"; mods = "control"; action = "resetfontsize"; } # Changed from "key0"
        ];
      };
    };

  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$character";

      character = {
        success_symbol = "[▶](bold red)";
        error_symbol = "[▶](bold dim red)";
        vimcmd_symbol = "[◀](bold blue)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };
      git_branch = {
        symbol = "⋆ ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        style = "red";
        format = "[$all_status$ahead_behind]($style)";
        conflicted = "×";
        ahead = "↑";
        behind = "↓";
        diverged = "↕";
        up_to_date = "";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
      nodejs.disabled = false;
      python.disabled = true;
      ruby.disabled = true;
      rust.disabled = false;
      java.disabled = true;
      golang.disabled = true;
      package.disabled = true;
      cmd_duration.disabled = false;
      time.disabled = false;
    };
  };

  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      hide_session_name = true;
      theme = "tokyo-night";
      themes.tokyo-night = {
        bg = "#1a1b26";
        fg = "#c0caf5";
        red = "#f7768e";
        green = "#9ece6a";
        blue = "#7aa2f7";
        yellow = "#e0af68";
        magenta = "#bb9af7";
        orange = "#ff9e64";
        cyan = "#7dcfff";
        black = "#15161e";
        white = "#c0caf5";
      };
    };
  };

  home.packages = with pkgs; [
    eza # ls replacement with icons and more features
    bat # cat clone with syntax highlighting and git integration
    ripgrep # fast grep alternative
    fd # simple and fast find alternative
    fzf # command-line fuzzy finder
    zoxide # smarter cd command, learns your habits
    fastfetch

    zellij
  ];
}
