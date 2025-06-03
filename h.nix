{ pkgs, lib, ... }:
let
  clipboard-notify-script = pkgs.writeShellScriptBin "clipboard-notify" ''
    PREV_CLIPBOARD=""
    while true; do
      CURRENT=$(${pkgs.wl-clipboard}/bin/wl-paste -n 2>/dev/null || echo "")
      if [[ "$CURRENT" != "$PREV_CLIPBOARD" && -n "$CURRENT" ]]; then
        ${pkgs.libnotify}/bin/notify-send "クリップボード" "新しい内容がコピーされました" -t 2000
        PREV_CLIPBOARD="$CURRENT"
      fi
      sleep 2
    done
  '';
in
{
  imports = [
    /home/wlmr/NixOS/modules/hyprland.nix
    /home/wlmr/NixOS/modules/terminal.nix
    /home/wlmr/NixOS/modules/apps.nix
    /home/wlmr/NixOS/modules/games.nix
    # /home/wlmr/NixOS/modules/development.nix
  ];

  home = {
    homeDirectory = "/home/wlmr";
    stateVersion = "25.11";
    packages = with pkgs; [
      nixpkgs-fmt
      nixd
      statix
      deadnix

      bitwarden-cli

      clipboard-notify-script
    ];
  };
}
