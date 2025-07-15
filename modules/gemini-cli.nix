# /home/wlmr/NixOS/modules/gemini-cli.nix

{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage rec {
  pname = "@google/gemini-cli";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "google-gemini";
    repo = "gemini-cli";
    rev = "v${version}";
    # Hash for the source code of v0.4.1
    hash = "sha256-4S3cnG/n4A7G/G0FlS9gZ2L0n98B/eH3I+z8g8g7H7g=";
  };

  # Hash for the node module dependencies of v0.4.1
  npmDepsHash = "sha256-sC/z4j189S2T5ub93v2aV5N2wPU63aGYjWtQk22t7aU=";

  # The official package has a postinstall script we need to skip for Nix builds
  npmBuildFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "The official command-line interface for Google Gemini";
    homepage = "https://github.com/google-gemini/gemini-cli";
    license = licenses.asl20;
    maintainers = with maintainers; [ "wlmr" ];
    platforms = platforms.unix;
  };
}
