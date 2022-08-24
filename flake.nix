{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    satysfi-upstream.url = "github:SnO2WMaN/SATySFi/sno2wman/nix-flake";
    satysfi-formatter-upstream.url = "github:SnO2WMaN/satysfi-formatter/nix-integrate";
    satysfi-language-server-upstream.url = "github:SnO2WMaN/satysfi-language-server/nix-integrate";
    yamlfmt-upstream.url = "github:SnO2WMaN/yamlfmt/nix-intgl";

    satyxin.url = "github:SnO2WMaN/satyxin";
    satysfi-sno2wman.url = "github:SnO2WMaN/satysfi-sno2wman";

    # dev
    devshell.url = "github:numtide/devshell";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            satyxin.overlays.default
            satysfi-formatter-upstream.overlays.default
            satysfi-sno2wman.overlays.default
            (final: prev: {
              satysfi = satysfi-upstream.packages.${system}.satysfi;
              satysfi-language-server = satysfi-language-server-upstream.packages.${system}.satysfi-language-server;
              yamlfmt = yamlfmt-upstream.packages.${system}.yamlfmt;
            })
          ];
        };
      in rec {
        packages = rec {
          satysfi-dist = pkgs.satyxin.buildSatysfiDist {
            packages = with pkgs.satyxinPackages; [
              dist
              class-yabaitech
              sno2wman
            ];
          };
          book = pkgs.satyxin.buildDocument {
            satysfiDist = satysfi-dist;
            name = "book";
            src = ./src;
            entrypoint = "book.saty";
          };
        };
        defaultPackage = self.packages."${system}".book;

        devShell = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            satysfi
            satysfi-formatter-write-each
            satysfi-language-server
            treefmt
            yamlfmt
          ];
        };
      }
    );
}
