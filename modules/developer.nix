# developer.nix
# This file defines development shells for different programming languages.
# To use a shell, run: nix-shell developer.nix -A <shellName>
# For example: nix-shell developer.nix -A rustDev

{ pkgs ? import <nixpkgs> { } }:

let
  # Common Rust development tools
  rustPackages = [
    pkgs.rustc # The Rust compiler
    pkgs.cargo # Rust's package manager and build tool
    pkgs.rust-analyzer # Language Server for Rust (great for Neovim)
    pkgs.clippy # Rust linter for catching common mistakes
    pkgs.rustfmt # Rust code formatter
    pkgs.gdb # GNU Debugger, useful for native debugging

    # Common build dependencies for Rust crates
    pkgs.openssl
    pkgs.pkg-config
    pkgs.zlib # Often needed by various libraries
  ];

  # JavaScript development tools
  jsPackages = [
    pkgs.nodejs_20 # Node.js (includes npm), version 20 LTS
    # pkgs.yarn          # Uncomment if you prefer Yarn over npm
    # pkgs.nodePackages.pnpm # Uncomment if you prefer pnpm
  ];

  # Kotlin development tools
  kotlinPackages = [
    pkgs.temurin-bin-17 # Eclipse Temurin OpenJDK 17 (a good LTS choice)
    # pkgs.jdk           # Alternatively, use pkgs.jdk for the default version in nixpkgs
    pkgs.kotlin # The Kotlin compiler and runtime
    pkgs.gradle # A powerful build tool, common for Kotlin/Java projects
  ];

  # Bash scripting tools
  bashScriptingPackages = [
    pkgs.bashInteractive # An enhanced Bash shell
    pkgs.shellcheck # Static analysis tool for shell scripts
    pkgs.shfmt # Shell script formatter
    pkgs.ripgrep # Fast search tool, very handy
    pkgs.fd # Simple and fast alternative to `find`
  ];

in
{
  # Rust Development Shell
  rustDev = pkgs.mkShell {
    name = "rust-dev-environment";
    buildInputs = rustPackages;
    shellHook = ''
      echo ""
      echo "  🌊 Entered Rust Development Shell 🌊"
      echo "  ------------------------------------"
      echo "  Rustc:    $(rustc --version)"
      echo "  Cargo:    $(cargo --version)"
      echo "  Tools:    rust-analyzer, clippy, rustfmt, gdb"
      echo "  Tip:      Run 'cargo new my_project' to start a new Rust project."
      echo ""
    '';
  };

  # JavaScript Development Shell
  jsDev = pkgs.mkShell {
    name = "javascript-dev-environment";
    buildInputs = jsPackages;
    shellHook = ''
      echo ""
      echo "  📜 Entered JavaScript Development Shell 📜"
      echo "  -----------------------------------------"
      echo "  Node:     $(node --version)"
      echo "  NPM:      $(npm --version)"
      # To add yarn version if uncommented above:
      # if command -v yarn &> /dev/null; then echo "  Yarn:     $(yarn --version)"; fi
      echo "  Tip:      Use 'npm init -y' or 'yarn init -y' to start a project."
      echo ""
    '';
  };

  # Kotlin Development Shell
  kotlinDev = pkgs.mkShell {
    name = "kotlin-dev-environment";
    buildInputs = kotlinPackages;
    shellHook = ''
      echo ""
      echo "  📱 Entered Kotlin Development Shell 📱"
      echo "  --------------------------------------"
      echo "  Kotlin:   $(kotlin -version 2>&1 | head -n 1 | sed -e 's/.*Kotlin version //')"
      echo "  Java:     $(java -version 2>&1 | head -n 1)"
      echo "  Gradle:   $(gradle --version | grep Gradle)"
      echo "  Tip:      Use 'gradle init' to start a new Kotlin project with Gradle."
      echo ""
    '';
  };

  # Bash Scripting Shell
  bashDev = pkgs.mkShell {
    name = "bash-scripting-environment";
    buildInputs = bashScriptingPackages;
    shellHook = ''
      echo ""
      echo "  ⚙️  Entered Bash Scripting Shell ⚙️"
      echo "  -----------------------------------"
      echo "  Bash:          $(bash --version | head -n1)"
      echo "  Shellcheck:    $(shellcheck --version | grep 'version:')"
      echo "  Tools:         shfmt, ripgrep, fd"
      echo "  Tip:           Use 'shellcheck your_script.sh' to lint."
      echo ""
    '';
  };
}
