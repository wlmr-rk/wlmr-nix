# /home/wlmr/NixOS/modules/terminal.nix
{ pkgs, lib, ... }:
let
  # Safely import ./developer.nix if it exists, otherwise use empty fishFunctions.
  oldDeveloperFishFunctions =
    if builtins.pathExists ./developer.nix then
      let
        # Attempt to import and get fishFunctions.
        # Add a check to ensure fishFunctions attribute exists in the imported file.
        importedConfig = import ./developer.nix { inherit pkgs lib; };
      in
      if builtins.hasAttr "fishFunctions" importedConfig then
        importedConfig.fishFunctions
      else
        { } # ./developer.nix exists but doesn't have fishFunctions
    else
      { }; # ./developer.nix does not exist

  terminalFishAliases = {
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

  terminalFishShellInit = ''
    set -x lc_all en_us.utf-8
    set -g fish_greeting ""
    if command -v zoxide >/dev/null
      zoxide init fish | source
    end
  '';
in
{
  options.fishContributions = {
    functions = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Fish functions contributed by this module.";
    };
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Fish shell aliases contributed by this module.";
    };
    shellInit = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Fish shell init script contributed by this module.";
    };
  };

  config = {
    fishContributions = {
      functions = oldDeveloperFishFunctions; # Use the safely acquired functions
      shellAliases = terminalFishAliases;
      shellInit = terminalFishShellInit;
    };

    programs.alacritty = {
      enable = true;
      settings = {
        env = { term = "xterm-256color"; };
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
          normal = { family = "jetbrains mono nerd font"; style = "regular"; };
          bold = { family = "jetbrains mono nerd font"; style = "bold"; };
          italic = { family = "jetbrains mono nerd font"; style = "italic"; };
          bold_italic = { family = "jetbrains mono nerd font"; style = "bold italic"; };
          size = 11;
          offset = { x = 0; y = 1; };
        };
        colors = {
          primary = { background = "0x000000"; foreground = "0xc0caf5"; dim_foreground = "0xa9b1d6"; };
          cursor = { text = "0x000000"; cursor = "0xc0caf5"; };
          vi_mode_cursor = { text = "0x000000"; cursor = "0x7aa2f7"; };
          selection = { text = "0xc0caf5"; background = "0x33467c"; };
          search = {
            matches = { foreground = "0x000000"; background = "0xff9e64"; };
            focused_match = { foreground = "0x000000"; background = "0xe0af68"; };
          };
          normal = { black = "0x15161e"; red = "0xf7768e"; green = "0x9ece6a"; yellow = "0xe0af68"; blue = "0x7aa2f7"; magenta = "0xbb9af7"; cyan = "0x7dcfff"; white = "0xa9b1d6"; };
          bright = { black = "0x414868"; red = "0xf7768e"; green = "0x9ece6a"; yellow = "0xe0af68"; blue = "0x7aa2f7"; magenta = "0xbb9af7"; cyan = "0x7dcfff"; white = "0xc0caf5"; };
        };
        bell = { animation = "easeoutexpo"; duration = 100; color = "0xff6b6b"; };
        keyboard.bindings = [
          { key = "v"; mods = "control|shift"; action = "paste"; }
          { key = "c"; mods = "control|shift"; action = "copy"; }
          { key = "Equals"; mods = "control"; action = "increasefontsize"; }
          { key = "Minus"; mods = "control"; action = "decreasefontsize"; }
          { key = "Key0"; mods = "control"; action = "resetfontsize"; }
        ];
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        format = "$directory$git_branch$git_status$character";
        character = { success_symbol = "[▶](bold red)"; error_symbol = "[▶](bold dim red)"; vimcmd_symbol = "[◀](bold blue)"; };
        directory = { style = "bold cyan"; truncation_length = 3; truncate_to_repo = true; format = "[$path]($style)[$read_only]($read_only_style) "; };
        git_branch = { symbol = "⋆ "; style = "bold purple"; format = "[$symbol$branch]($style) "; };
        git_status = { style = "red"; format = "[$all_status$ahead_behind]($style)"; conflicted = "×"; ahead = "↑"; behind = "↓"; diverged = "↕"; up_to_date = ""; untracked = "?"; stashed = "$"; modified = "!"; staged = "+"; renamed = "»"; deleted = "✘"; };
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
        themes.tokyo-night = { bg = "#1a1b26"; fg = "#c0caf5"; red = "#f7768e"; green = "#9ece6a"; blue = "#7aa2f7"; yellow = "#e0af68"; magenta = "#bb9af7"; orange = "#ff9e64"; cyan = "#7dcfff"; black = "#15161e"; white = "#c0caf5"; };
      };
    };

    home.packages = with pkgs; [
      eza
      bat
      ripgrep
      fd
      fzf
      zoxide
      fastfetch
      zellij
    ];
  };
}
