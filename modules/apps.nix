# GUI Applications
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [

    (writeShellScriptBin "fuzzel-enhanced" ''
      #!/bin/bash
    
      # Command history file
      HISTORY_FILE="$HOME/.cache/fuzzel_commands"
      CURRENT_DATE=$(date '+%Y年%m月%d日 (%a) %H:%M')
    
      case "$1" in
        "drun"|"")
          # Default app launcher with date in placeholder
          exec fuzzel --prompt="  > " --placeholder="$CURRENT_DATE | アプリ検索..." --lines=12
          ;;
        
        "search")
          # Web search mode - single line
          QUERY=$(echo "" | fuzzel --dmenu --prompt="  > " --placeholder="$CURRENT_DATE | Web検索..." --lines=0)
          if [ -n "$QUERY" ]; then
            firefox "https://www.google.com/search?q=$(echo "$QUERY" | sed 's/ /+/g')" &
          fi
          ;;
        
        "ai")
          # AI chat mode - single line
          QUERY=$(echo "" | fuzzel --dmenu --prompt="  > " --placeholder="$CURRENT_DATE | AI質問..." --lines=0)
          if [ -n "$QUERY" ]; then
            firefox "https://chat.openai.com/?q=$(echo "$QUERY" | sed 's/ /+/g')" &
          fi
          ;;
        
        "run")
          # Terminal command runner with history - single line for input
          touch "$HISTORY_FILE"
        
          COMMAND=$(tac "$HISTORY_FILE" | fuzzel --dmenu --prompt="  > " --placeholder="$CURRENT_DATE | コマンド入力..." --lines=12)
        
          if [ -n "$COMMAND" ]; then
            # Add to history (avoid duplicates)
            grep -Fxq "$COMMAND" "$HISTORY_FILE" || echo "$COMMAND" >> "$HISTORY_FILE"
          
            # Execute in alacritty
            alacritty -e fish -c "
              echo 'Executing: $COMMAND'
              eval $COMMAND
              read
            " &
          fi
          ;;
        
        *)
          echo "Usage: fuzzel-enhanced [drun|search|ai|run]"
          exit 1
          ;;
      esac
    '')
    firefox
    nautilus
    mpv
    imv
    vlc
    fuzzel
    qbittorrent
    ncspot
    gimp
    gnome-clocks
    gnome-calculator
    anki-bin
  ];

  programs.git = {
    enable = true;
    userEmail = "wlmr.rk@gmail.com";
    userName = "wlmr-rk";
  };

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono Nerd Font:size=12";
        terminal = "alacritty";
        width = 60;
        horizontal-pad = 16;
        vertical-pad = 8;
        inner-pad = 8;
        layer = "overlay";
        prompt = "実行 ";
        placeholder = "アプリ検索..."; # Date will be added by script
        icon-theme = "Papirus-Dark";
        lines = 12;
        tabs = 4;
        line-height = 20;
        letter-spacing = 0;
        mouse = false;
      };

      colors = {
        background = "0a0a0aef";
        text = "c0caf5ff";
        prompt = "bb9af7ff";
        placeholder = "565f89ff";
        input = "c0caf5ff";
        match = "7aa2f7ff";
        selection = "bb9af7ff";
        selection-text = "1a1b26ff";
        selection-match = "ffffff ff";
        border = "bb9af7ff";
      };

      border = {
        width = 1;
        radius = 0;
      };

      dmenu = {
        exit-immediately-if-empty = false;
        print-index = false;
        mode = "text";
        mouse = false;
      };

      key-bindings = {
        cancel = "Escape ctrl+c";
        execute = "Return KP_Enter";
        execute-or-next = "Tab";
        delete-prev = "BackSpace";
        delete-next = "Delete";
      };
    };
  };
}
