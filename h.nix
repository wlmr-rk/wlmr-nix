# /home/wlmr/NixOS/h.nix
{ pkgs, lib, config, ... }: # Added 'config' to access merged configurations from imported modules
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

  # Import your new development module
  developmentConfig = import /home/wlmr/NixOS/modules/development.nix { inherit pkgs lib; };
in
{
  imports = [
    /home/wlmr/NixOS/modules/hyprland.nix
    /home/wlmr/NixOS/modules/terminal.nix # This now contributes config.fishContributions
    /home/wlmr/NixOS/modules/apps.nix
    /home/wlmr/NixOS/modules/games.nix
    # development.nix is not added to imports here because we are using its attributes directly
    # via 'developmentConfig'. If it defined options, you might import it.
  ];

  home = {
    homeDirectory = "/home/wlmr";
    stateVersion = "25.11"; # Keep your state version
    packages = with pkgs; [
      nixpkgs-fmt
      nixd
      statix
      deadnix
      bitwarden-cli
      clipboard-notify-script
    ] ++ developmentConfig.packages; # Add packages from development.nix
  };

  programs.fish = {
    enable = true;
    # Merge functions:
    # config.fishContributions.functions comes from terminal.nix (which includes functions from its ./developer.nix import)
    # developmentConfig.fishFunctions comes from our new development.nix
    # The '//' operator means that if a function name collides, the one from developmentConfig takes precedence.
    functions = (config.fishContributions.functions // developmentConfig.fishFunctions);

    # Aliases and ShellInit from terminal.nix (via its contribution)
    shellAliases = config.fishContributions.shellAliases;
    shellInit = config.fishContributions.shellInit;
  };

  # ... any other configurations you had in h.nix ...
  # For example, if you had xdg.userDirs, keep it:
  # xdg.userDirs = {
  #   enable = true;
  #   # ... etc
  # };
}
