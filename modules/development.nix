# /home/wlmr/NixOS/modules/development.nix
{ pkgs, ... }:

let
  # Template for Rust shell.nix
  rustShellNixFile = pkgs.writeText "rust-shell-template.nix" ''
    { pkgs ? import <nixpkgs> {} }:

    pkgs.mkShell {
      name = "rust-dev-env";
      buildInputs = with pkgs; [
        rustc cargo rust-analyzer openssl pkg-config llvmPackages.libclang
        rustfmt clippy lld bacon gcc glibc.dev dioxus-cli
      ];
      CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "${pkgs.gcc}/bin/gcc";
      RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
      RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
      shellHook = ''' 
        export PS1="🦀(rust-dev) $PS1" # $PS1 for shell's $PS1, not Nix's
        echo "🦀 Rust development environment activated!"
      '''; 
    }
  '';

  # Template for JavaScript/TypeScript shell.nix
  javascriptShellNixFile = pkgs.writeText "js-shell-template.nix" ''
    { pkgs ? import <nixpkgs> {} }:

    pkgs.mkShell {
      name = "js-ts-dev-env";
      buildInputs = with pkgs; [ nodejs_20 yarn ];
      shellHook = ''' 
        echo "📜 JavaScript/TypeScript development environment activated!"
        echo "   To start a new project: yarn init (or npm init)"
      '''; 
    }
  '';

  internalCreateDevShellScript = pkgs.runCommandLocal "internal-create-dev-shell"
    {
      scriptContent = ''#!${pkgs.fish}/bin/fish
# Script to create a shell.nix in the current directory.
# Usage: internal-create-dev-shell <type>
# <type> can be "rust" or "js"

set type $argv[1]
set current_dir (pwd) # Changed PWD to current_dir
set SHELL_NIX_PATH "$current_dir/shell.nix" # Use current_dir

set template_file ""
set lang_name ""

if test "$type" = "rust"
  set template_file "${rustShellNixFile}"
  set lang_name "Rust"
else if test "$type" = "js"
  set template_file "${javascriptShellNixFile}"
  set lang_name "JavaScript/TypeScript"
else
  echo "Error (internal script): Unknown development environment type '$type'." >&2
  echo "Supported types: rust, js" >&2
  exit 1
end

if test -e "$SHELL_NIX_PATH"
  echo -n "⚠️  Warning: '$SHELL_NIX_PATH' already exists. Overwrite? (y/N): "
  read confirm
  set confirm_lower (string lower -- "$confirm")
  if test "$confirm_lower" != "y"
    echo "↪️  Aborted. '$SHELL_NIX_PATH' was not changed."
    exit 0
  end
end

if ${pkgs.coreutils}/bin/cp "$template_file" "$SHELL_NIX_PATH"
  echo "✅ $lang_name 'shell.nix' created at '$SHELL_NIX_PATH'"
  echo "   You can now run the original 'nix-shell' command in this directory to activate it."
  echo "   Pro-tip: For automatic activation, create an '.envrc' file with:"
  echo "            echo 'use nix' > .envrc  (requires direnv and nix-direnv)"
  nix-shell
else
  echo "❌ Error: Failed to write '$SHELL_NIX_PATH'" >&2
  exit 1
end
'';
    }
    '' 
      mkdir -p $out/bin
      printf "%s" "$scriptContent" > $out/bin/internal-create-dev-shell
      chmod +x $out/bin/internal-create-dev-shell
    '';
in
{
  fishFunctions = {
    "nix-shell" = ''
      set real_nix_shell (command -s nix-shell)
      if test -z "$real_nix_shell"; if test -x "${pkgs.nix}/bin/nix-shell"; set real_nix_shell "${pkgs.nix}/bin/nix-shell"; else; echo "Error: Could not reliably determine the path to the original 'nix-shell' command." >&2; command nix-shell $argv; return $status; end; end
      if test (count $argv) -eq 0; or string match -q -- "-*" "$argv[1]"; or test -e "$argv[1]"; or string match -q -- "*.nix" "$argv[1]"; eval "$real_nix_shell $argv"; return $status; end
      switch "$argv[1]"
        case "js" "javascript"; ${internalCreateDevShellScript}/bin/internal-create-dev-shell js; return $status
        case "rust"; ${internalCreateDevShellScript}/bin/internal-create-dev-shell rust; return $status
        case "--help-custom"; echo "🛠️  Custom 'nix-shell' commands provided by development.nix:"; echo "  nix-shell js          - Create a JavaScript/TypeScript shell.nix in the current directory."; echo "  nix-shell rust        - Create a Rust shell.nix in the current directory."; echo ""; echo "All other arguments are passed to the original 'nix-shell' command."; echo "To see original help: $real_nix_shell --help"; return 0
        case "*"; eval "$real_nix_shell $argv"; return $status
      end
    '';
  };
}
