{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, flake-utils, poetry2nix, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = (import nixpkgs {
        inherit system;
        overlays = [ poetry2nix.overlay ];
      });
      in rec {
        packages = {
          app = pkgs.poetry2nix.mkPoetryApplication {
            python = pkgs.python39;
            projectDir = ./.;
            preferWheels = true;
            doCheck = true;
            checkPhase = "python -m pytest";
          };
        };

        # devShell = packages.env.env.overrideAttrs (old: { buildInputs = [ pkgs.poetry ]; });
        devShell = pkgs.mkShell { buildInputs = [ pkgs.poetry ]; };
      });
}
