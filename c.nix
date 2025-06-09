# configuration.nix

{ pkgs, ... }:
{
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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    # Development essentials (consolidated)
    stdenv.cc # Includes clang, gcc, and essential build tools
    nodejs_latest # Keep for your React/JS work
    lua-language-server
    neovim
    git
    rustlings
    jq
    google-chrome

    # Add these for Rust GUI development
    wayland
    wayland-protocols
    libxkbcommon
    libGL
    pkg-config
    deno

    # X11 fallback support
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi

    # System utilities (consolidated) 
    busybox # Replaces: curl, wget, unzip (includes 300+ utilities)
    pkg-config # Essential for building

    # Hardware/Graphics
    qt6.qtwayland
    rocmPackages.clr # OpenCL runtime (includes what clr-icd provides)
    rocmPackages.rocminfo

    # Desktop environment
    udisks2 # Auto-mounting (udiskie can be user service)
    libxkbcommon # Wayland keyboard support
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
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    ANKI_WAYLAND = "1";
    GDK_BACKEND = "wayland";
    NIXOS_OZONE_WL = "1";

    WAYLAND_DISPLAY = "wayland-1";
    XDG_SESSION_TYPE = "wayland";
  };
  environment.variables = {
    GDK_SCALE = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "alacritty";
    SHELL = "fish";
  };
  system.stateVersion = "25.11";
}
