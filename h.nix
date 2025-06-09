# /home/wlmr/NixOS/h.nix
{ pkgs, lib, config, ... }:
let
  developmentConfig = import /home/wlmr/NixOS/modules/development.nix { inherit pkgs lib; };

  shadps4-local = pkgs.appimageTools.wrapType2 {
    pname = "shadps4";
    version = "0.9A";
    src = /home/wlmr/Downloads/shadps4plus.AppImage;

    extraPkgs = pkgs: with pkgs; [
      vulkan-loader
      libGL
      alsa-lib
      libpulseaudio
    ];
  };
in
{
  imports = [
    /home/wlmr/NixOS/modules/hyprland.nix
    /home/wlmr/NixOS/modules/terminal.nix
    /home/wlmr/NixOS/modules/apps.nix
    /home/wlmr/NixOS/modules/games.nix
  ];

  home = {
    homeDirectory = "/home/wlmr";
    stateVersion = "25.11";
    packages = with pkgs; [
      android-studio
      nixpkgs-fmt
      nix
      statix
      deadnix

      bitwarden-cli
      shadps4-local

      pavucontrol
      networkmanagerapplet

      rustup
      wasm-bindgen-cli
      wayland
      wayland-protocols
      marksman

      obsidian

      # ollama-rocm
    ];
  };

  programs.fish = {
    enable = true;
    functions = config.fishContributions.functions // developmentConfig.fishFunctions;
    inherit (config.fishContributions) shellAliases shellInit;
  };
}
