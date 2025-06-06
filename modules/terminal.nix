# /home/wlmr/NixOS/modules/terminal.nix
{ pkgs, lib, config, ... }:
let
  # Import developer functions more robustly
  oldDeveloperFishFunctions =
    if builtins.pathExists ./developer.nix then
      let
        importedConfig = import ./developer.nix { inherit pkgs lib; };
      in
        importedConfig.fishFunctions or { }
    else
      { };

  # Fixed clipboard monitoring script
  clipboardMonitorScript = pkgs.writeShellScript "clipboard-monitor" ''
    #!/bin/bash
    
    # Kill any existing clipboard monitors to prevent duplicates
    pkill -f "wl-paste.*clipboard-monitor" || true
    
    # Store last clipboard content to avoid duplicate notifications
    CLIP_HISTORY_FILE="$HOME/.cache/clipboard_history"
    
    # Ensure cache directory exists
    mkdir -p "$(dirname "$CLIP_HISTORY_FILE")"
    
    # Function to get clipboard content hash for comparison
    get_clip_hash() {
        wl-paste 2>/dev/null | sha256sum | cut -d' ' -f1 2>/dev/null || echo ""
    }
    
    # Function to show notification with content preview
    show_notification() {
        local content="$1"
        local content_type="$2"
        local preview
        
        # Truncate long content for preview
        if [ ''${#content} -gt 100 ]; then
            preview="''${content:0:97}..."
        else
            preview="$content"
        fi
        
        # Different icons based on content type
        case "$content_type" in
            "image") 
                notify-send -i "image-x-generic" "📋 Clipboard" "Image copied"
                ;;
            "url")
                notify-send -i "applications-internet" "🔗 Clipboard" "URL: $preview"
                ;;
            "text")
                notify-send -i "edit-copy" "📋 Clipboard" "$preview"
                ;;
        esac
    }
    
    # Export functions so they're available to subshells
    export -f get_clip_hash
    export -f show_notification
    
    # Monitor clipboard changes with a more robust approach
    wl-paste --watch bash -c '
        # Re-source the functions in this subshell context
        get_clip_hash() {
            wl-paste 2>/dev/null | sha256sum | cut -d'"'"' '"'"' -f1 2>/dev/null || echo ""
        }
        
        show_notification() {
            local content="$1"
            local content_type="$2"
            local preview
            
            if [ ''${#content} -gt 100 ]; then
                preview="''${content:0:97}..."
            else
                preview="$content"
            fi
            
            case "$content_type" in
                "image") 
                    notify-send -i "image-x-generic" "📋 Clipboard" "Image copied"
                    ;;
                "url")
                    notify-send -i "applications-internet" "🔗 Clipboard" "URL: $preview"
                    ;;
                "text")
                    notify-send -i "edit-copy" "📋 Clipboard" "$preview"
                    ;;
            esac
        }
        
        CURRENT_HASH=$(get_clip_hash)
        
        # Skip if same as last clip
        if [ -f "'"$CLIP_HISTORY_FILE"'" ] && [ "$(cat "'"$CLIP_HISTORY_FILE"'")" = "$CURRENT_HASH" ]; then
            exit 0
        fi
        
        # Save current hash
        echo "$CURRENT_HASH" > "'"$CLIP_HISTORY_FILE"'"
        
        # Get clipboard content
        CONTENT=$(wl-paste 2>/dev/null || echo "")
        
        # Skip if empty
        [ -z "$CONTENT" ] && exit 0
        
        # Determine content type
        if wl-paste --list-types 2>/dev/null | grep -q "image"; then
            show_notification "" "image"
        elif echo "$CONTENT" | grep -qE "^https?://"; then
            show_notification "$CONTENT" "url"
        else
            show_notification "$CONTENT" "text"
        fi
    ' &
    
    # Keep the main script running
    wait
  '';

  # Enhanced Fish functions
  enhancedFishFunctions = oldDeveloperFishFunctions // {
    # Clipboard utilities
    clip = "wl-copy";
    paste = "wl-paste";

    # Directory navigation improvements
    mkcd = ''
      function mkcd
          mkdir -p $argv[1] && cd $argv[1]
      end
    '';

    up = ''
      function up
          set -l levels $argv[1]
          if test -z "$levels"
              set levels 1
          end
          set -l path ""
          for i in (seq $levels)
              set path "../$path"
          end
          cd $path
      end
    '';

    # File operations
    backup = ''
      function backup
          cp $argv[1] $argv[1].bak.(date +%Y%m%d_%H%M%S)
      end
    '';

    extract = ''
      function extract
          switch $argv[1]
              case "*.tar.bz2"
                  tar xjf $argv[1]
              case "*.tar.gz"
                  tar xzf $argv[1]
              case "*.bz2"
                  bunzip2 $argv[1]
              case "*.rar"
                  unrar x $argv[1]
              case "*.gz"
                  gunzip $argv[1]
              case "*.tar"
                  tar xf $argv[1]
              case "*.tbz2"
                  tar xjf $argv[1]
              case "*.tgz"
                  tar xzf $argv[1]
              case "*.zip"
                  unzip $argv[1]
              case "*.Z"
                  uncompress $argv[1]
              case "*.7z"
                  7z x $argv[1]
              case "*"
                  echo "Unknown archive format: $argv[1]"
          end
      end
    '';

    # System monitoring
    ports = "ss -tuln";
    processes = "ps aux | head -20";
    meminfo = "free -h";
    diskinfo = "df -h";

    # Development utilities
    serve = "python3 -m http.server 8000";
    myip = "curl -s https://httpbin.org/ip | jq -r .origin";
    weather = "curl -s 'wttr.in/?format=3'";

    # NixOS specific improvements
    nixtest = "sudo nixos-rebuild test --flake ~/NixOS";
    nixboot = "sudo nixos-rebuild boot --flake ~/NixOS";
    nixclean = "sudo nix-collect-garbage -d && nix-store --optimise";
    nixsearch = "nix search nixpkgs";
    nixshell = "nix-shell -p";
  };

  # Improved aliases
  terminalFishAliases = {
    # Enhanced ls alternatives
    ll = "eza -la --icons --git --header --group-directories-first";
    la = "eza -la --icons --git --header --group-directories-first";
    ls = "eza --icons --group-directories-first";
    lt = "eza --tree --icons --level=2";
    tree = "eza --tree --icons";

    # Better file tools
    cat = "bat --paging=never";
    less = "bat --paging=always";
    find = "fd";
    grep = "rg";

    # Config shortcuts (improved)
    nconf = "nvim ~/NixOS/configuration.nix";
    nhome = "nvim ~/NixOS/home.nix";
    napp = "nvim ~/NixOS/modules/apps.nix";
    nhypr = "nvim ~/NixOS/modules/hyprland.nix";
    nterm = "nvim ~/NixOS/modules/terminal.nix";

    # Quick navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # Safety nets
    rm = "rm -i";
    cp = "cp -i";
    mv = "mv -i";

    # Network
    ping = "ping -c 5";

    # Modern alternatives
    top = "btop";
    htop = "btop";
    du = "dust";
    df = "duf";
  };

  # Enhanced shell initialization
  terminalFishShellInit = ''
    set -gx NODE_NO_WARNINGS 1
    
    set -gx ANKI_WAYLAND 1
    set -gx QT_QPA_PLATFORM wayland
    set -gx QT_WAYLAND_DISABLE_WINDOWDECORATION 1
    set -gx MOZ_ENABLE_WAYLAND 1
    set -gx ELECTRON_OZONE_PLATFORM_HINT wayland
    set -gx LC_ALL en_US.UTF-8
    set -gx LANG en_US.UTF-8
    set -g fish_greeting ""
    set -g fish_history_file ~/.local/share/fish/fish_history
    set -g fish_history_size 10000
    
    # Initialize tools
    if command -v zoxide >/dev/null
        zoxide init fish | source
    end
    
    if command -v direnv >/dev/null
        direnv hook fish | source
    end
    
    # Start clipboard monitor (improved with better process checking)
    if not pgrep -f "clipboard-monitor" >/dev/null 2>&1
        nohup ${clipboardMonitorScript} >/dev/null 2>&1 & disown
    end
    
    # Auto-completion enhancements
    if command -v gh >/dev/null
        gh completion -s fish | source
    end
    
    # Custom key bindings
    bind \cf 'fzf | head -1 | read -l result; and commandline -a "$result"'
    bind \cr 'history | fzf | read -l result; and commandline -r "$result"'
    bind \co 'fd --type f | fzf | read -l result; and $EDITOR "$result"'
    
    # Functions for session management
    function last_history_item
        echo $history[1]
    end
    
    # Smart cd with auto-ls
    function cd
        builtin cd $argv
        and ls
    end
    
    # Enhanced prompt customization
    set -g fish_prompt_pwd_dir_length 3
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
      functions = enhancedFishFunctions;
      shellAliases = terminalFishAliases;
      shellInit = terminalFishShellInit;
    };

    # Enhanced Alacritty configuration
    programs.alacritty = {
      enable = true;
      settings = {
        env = {
          TERM = "xterm-256color";
          COLORTERM = "truecolor";
        };

        window = {
          padding = { x = 20; y = 12; };
          opacity = 0.92;
          blur = true;
          decorations = "buttonless";
          startup_mode = "windowed";
          title = "ターミナル";
          dynamic_title = true;
          dynamic_padding = true;
          option_as_alt = "both";
        };

        scrolling = {
          history = 100000; # Increased for better history
          multiplier = 3;
        };

        font = {
          normal = { family = "JetBrains Mono Nerd Font"; style = "Regular"; };
          bold = { family = "JetBrains Mono Nerd Font"; style = "Bold"; };
          italic = { family = "JetBrains Mono Nerd Font"; style = "Italic"; };
          bold_italic = { family = "JetBrains Mono Nerd Font"; style = "Bold Italic"; };
          size = 11.0;
          offset = { x = 0; y = 1; };
          glyph_offset = { x = 0; y = 0; };
          builtin_box_drawing = true;
        };

        # Enhanced Tokyo Night color scheme
        colors = {
          primary = {
            background = "#1a1b26";
            foreground = "#c0caf5";
            dim_foreground = "#a9b1d6";
            bright_foreground = "#c0caf5";
          };
          cursor = {
            text = "CellBackground";
            cursor = "#c0caf5";
          };
          selection = {
            text = "CellForeground";
            background = "#33467c";
          };
          search = {
            matches = { foreground = "#1a1b26"; background = "#ff9e64"; };
            focused_match = { foreground = "#1a1b26"; background = "#e0af68"; };
          };
          line_indicator = {
            foreground = "None";
            background = "None";
          };
          normal = {
            black = "#15161e";
            red = "#f7768e";
            green = "#9ece6a";
            yellow = "#e0af68";
            blue = "#7aa2f7";
            magenta = "#bb9af7";
            cyan = "#7dcfff";
            white = "#a9b1d6";
          };
          bright = {
            black = "#414868";
            red = "#f7768e";
            green = "#9ece6a";
            yellow = "#e0af68";
            blue = "#7aa2f7";
            magenta = "#bb9af7";
            cyan = "#7dcfff";
            white = "#c0caf5";
          };
          dim = {
            black = "#32344a";
            red = "#f7768e";
            green = "#9ece6a";
            yellow = "#e0af68";
            blue = "#7aa2f7";
            magenta = "#bb9af7";
            cyan = "#7dcfff";
            white = "#9aa5ce";
          };
        };

        bell = {
          animation = "EaseOutExpo";
          duration = 100;
          color = "#ff6b6b";
        };

        keyboard.bindings = [
          { key = "V"; mods = "Control|Shift"; action = "Paste"; }
          { key = "C"; mods = "Control|Shift"; action = "Copy"; }
          { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
          { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
          { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        ];

        mouse = {
          hide_when_typing = true;
        };

        # Performance optimizations
        debug = {
          render_timer = false;
          persistent_logging = false;
          log_level = "Warn";
          print_events = false;
        };
      };
    };

    # Enhanced Starship prompt
    programs.starship = {
      enable = true;
      settings = {
        format = lib.concatStrings [
          "$username"
          "$hostname"
          "$directory"
          "$git_branch"
          "$git_status"
          "$git_state"
          "$git_metrics"
          "$fill"
          "$nodejs"
          "$rust"
          "$python"
          "$cmd_duration"
          "$line_break"
          "$character"
        ];

        # Enhanced character prompt
        character = {
          success_symbol = "[▶](bold green)";
          error_symbol = "[▶](bold red)";
          vimcmd_symbol = "[◀](bold blue)";
        };

        # Better directory display
        directory = {
          style = "bold cyan";
          truncation_length = 4;
          truncate_to_repo = true;
          format = "[$path]($style)[$read_only]($read_only_style) ";
          home_symbol = "~";
          truncation_symbol = ".../";
        };

        # Enhanced git info
        git_branch = {
          symbol = "⋆ ";
          style = "bold purple";
          format = "[$symbol$branch]($style) ";
          truncation_length = 20;
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

        git_metrics = {
          disabled = false;
          added_style = "bold green";
          deleted_style = "bold red";
          format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
        };

        # Command duration
        cmd_duration = {
          disabled = false;
          format = "took [$duration]($style) ";
          style = "yellow";
          min_time = 2000;
        };

        # Fill line
        fill = {
          symbol = " ";
        };

        # Language-specific modules
        nodejs = {
          disabled = false;
          format = "[$symbol($version )]($style)";
          symbol = "⬢ ";
          style = "green";
        };

        rust = {
          disabled = false;
          format = "[$symbol($version )]($style)";
          symbol = "🦀 ";
          style = "red";
        };

        python = {
          disabled = false;
          format = "[$symbol$pyenv_prefix($version )($virtualenv )]($style)";
          symbol = "🐍 ";
          style = "yellow";
        };

        # Disable noisy modules
        aws.disabled = true;
        gcloud.disabled = true;
        kubernetes.disabled = true;
        docker_context.disabled = true;
        java.disabled = true;
        golang.disabled = true;
        package.disabled = true;
        time.disabled = true;
      };
    };

    # Essential packages with modern alternatives
    home.packages = with pkgs; [
      eza # ls replacement
      bat # cat replacement
      ripgrep # grep replacement
      fd # find replacement
      fzf # fuzzy finder
      zoxide # cd replacement
      dust # du replacement
      duf # df replacement
      btop # top/htop replacement
      libnotify # for notify-send
      wl-clipboard # for wl-copy/wl-paste
    ];

    # Additional services for clipboard monitoring
    systemd.user.services.clipboard-monitor = {
      Unit = {
        Description = "Enhanced clipboard monitor";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${clipboardMonitorScript}";
        Restart = "on-failure";
        RestartSec = "5s";
        Environment = [
          "PATH=${lib.makeBinPath (with pkgs; [ wl-clipboard libnotify coreutils bash ])}"
          "DISPLAY=:0"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
