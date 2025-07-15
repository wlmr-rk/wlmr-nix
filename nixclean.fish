function nixclean
    sudo nix-collect-garbage -d && nix-store --optimise
end
