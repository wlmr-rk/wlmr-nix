{ pkgs, ... }:
{
  home.packages = with pkgs;
    [
      bubblewrap
      fuse-overlayfs
      steam-run
      dwarfs
      jemalloc
      wine
      winetricks
      bottles
    ];

  xdg.userDirs.extraConfig = {
    XDG_GAMES_DIR = "$HOME/Games";
  };
}
