#!/usr/bin/env fish

function sync --description "Sync NixOS configuration files and rebuild system"
    # Set the absolute path to your NixOS configuration directory
    set -l nixos_dir "$HOME/NixOS"

    # Check if the NixOS directory exists
    if not test -d "$nixos_dir"
        echo "❌ Error: NixOS directory not found at $nixos_dir"
        echo "Please ensure your configuration files are in ~/NixOS/"
        return 1
    end

    # Check if configuration files exist
    if not test -f "$nixos_dir/h.nix" -o -f "$nixos_dir/c.nix"
        echo "❌ Error: h.nix or c.nix not found in $nixos_dir"
        echo "Please ensure your configuration files are properly named"
        return 1
    end

    # Colors for output (Tokyo Night inspired)
    set -l cyan "\033[96m"
    set -l blue "\033[94m"
    set -l green "\033[92m"
    set -l yellow "\033[93m"
    set -l red "\033[91m"
    set -l reset "\033[0m"
    set -l bold "\033[1m"

    echo -e "$bold$blue📋 NixOS Configuration Sync$reset"

    # Step 1: Backup current files
    echo -e "$yellow🔄 Creating backups...$reset"
    if test -f "/etc/nixos/configuration.nix"
        sudo cp /etc/nixos/configuration.nix /etc/nixos/.backup/configuration.nix.backup.(date +%Y%m%d_%H%M%S)
        echo -e "$green  ✓ Backed up configuration.nix$reset"
    end

    if test -f "/etc/nixos/home.nix"
        sudo cp /etc/nixos/home.nix /etc/nixos/.backup/home.nix.backup.(date +%Y%m%d_%H%M%S)
        echo -e "$green  ✓ Backed up home.nix$reset"
    end

    # Step 2: Copy files
    echo -e "$yellow🔄 Copying configuration files...$reset"

    if test -f "$nixos_dir/c.nix"
        sudo cp "$nixos_dir/c.nix" /etc/nixos/configuration.nix
        echo -e "$green  ✓ Copied $nixos_dir/c.nix → /etc/nixos/configuration.nix$reset"
    else
        echo -e "$red  ❌ c.nix not found in $nixos_dir$reset"
        return 1
    end

    if test -f "$nixos_dir/h.nix"
        sudo cp "$nixos_dir/h.nix" /etc/nixos/home.nix
        echo -e "$green  ✓ Copied $nixos_dir/h.nix → /etc/nixos/home.nix$reset"
    else
        echo -e "$red  ❌ h.nix not found in $nixos_dir$reset"
        return 1
    end

    # Step 3: Rebuild system
    echo -e "$yellow🔄 Rebuilding NixOS system...$reset"
    echo -e "$cyan  This may take a few minutes...$reset"

    if sudo nixos-rebuild switch
        echo -e "$bold$green🎉 NixOS system successfully rebuilt and configured!$reset"
        echo -e "$cyan  Your Tokyo Night themed setup is ready to go ✨$reset"
    else
        echo -e "$red❌ NixOS rebuild failed! Check the error messages above.$reset"
        echo -e "$yellow  Your backup files are available in /etc/nixos/$reset"
        return 1
    end

    # Display summary
    echo -e "$bold$blue📊 Sync Summary:$reset"
    echo -e "$green  ✓ Configuration files synced from $nixos_dir$reset"
    echo -e "$green  ✓ System rebuilt successfully$reset"
    echo -e "$green  ✓ Home Manager configuration applied$reset"
end
