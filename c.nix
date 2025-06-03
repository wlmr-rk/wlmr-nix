# configuration.nix

{ config, pkgs, lib, ... }:
{
  #  environment.variables = {
  #    AMD_VULKAN_ICD = "RADV";
  #    MOZ_DISABLE_RDD = "1";
  #    MOZ_ACCELERATED = "1";
  #    MOZ_WEBRENDER = "1";
  #  };
  #
  #  boot.initrd.kernelModules = [ "amdgpu" ];
  #  boot.kernelModules = [ "amdgpu" ];

  imports = [
    <nixos-hardware/common/gpu/amd/default.nix>
    <home-manager/nixos>
    ./hardware-configuration.nix
  ];

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu.amdvlk = {
      enable = true;
      support32Bit.enable = true;
    };
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "amdgpu.sg_display=0" "amdgpu.dc=1" ];

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  services.chrony = {
    enable = true;
    servers = [ "pool.ntp.org" "time.cloudflare.com" ];
  };
  time.timeZone = "Asia/Manila";

  services.getty.autologinUser = "wlmr";
  services.dbus.enable = true;
  services = {
    gvfs.enable = true;
    udisks2 = {
      enable = true;
      mountOnMedia = true;
    };
    timesyncd.enable = false;
    displayManager.ly.enable = true;
    pulseaudio.enable = false;
    xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  programs.steam.enable = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
  };

  users.users.wlmr = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "storage" "dialout" ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.android_sdk.accept_license = true; # Android Studio

  environment.systemPackages = with pkgs; [
    udisks2
    udiskie
    neovim
    libxkbcommon
    git
    curl
    pkg-config
    unzip
    wget
    pavucontrol
    networkmanagerapplet
    playerctl
    bibata-cursors
    btop
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.cache32Bit = true;

  # xdg = {
  #   userDirs = {
  #     enable = true;
  #     createDirectories = true;
  #   };
  # };


  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.wlmr = import ./home.nix;
  };

  home-manager.backupFileExtension = "backup-$(date +%Y%m%d)";
  environment.variables = {
    GDK_BACKEND = "wayland";
    GDK_SCALE = "1";
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "alacritty";
    SHELL = "fish";
  };
  system.stateVersion = "25.11";
}
