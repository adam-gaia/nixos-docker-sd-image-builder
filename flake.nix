{
  description = "TODO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    flake-utils,
    treefmt-nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };
      inherit (pkgs) lib;
      toolchain = with pkgs; [
        rpi-imager
        docker-compose
        (treefmt-nix.lib.mkWrapper pkgs (import ./treefmt.nix))
      ];

      build-img = pkgs.writeShellApplication {
        name = "build-img";
        text = builtins.readFile ./build-img;
      };
    in {
      defaultPackage = build-img;
      devShells.default = pkgs.mkShell {
        # Tools that should be avaliable in the shell
        nativeBuildInputs = toolchain;
      };
    });
}
