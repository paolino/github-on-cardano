{
  inputs = {
    haskellNix = { url = "github:input-output-hk/haskell.nix"; };
    nixpkgs = {
      url = "github:NixOS/nixpkgs";
      follows = "haskellNix/nixpkgs-unstable";
    };
    iohkNix = {
      url = "github:input-output-hk/iohk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:hamishmack/flake-utils/hkm/nested-hydraJobs";
    };
  };
  outputs = inputs@{ self, nixpkgs, haskellNix, iohkNix, flake-utils }:
    let
      src = ./.;
      indexState = "2025-03-22T00:00:00Z";
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      perSystem = system:
        let
          pkgs = import nixpkgs {
            overlays = [ haskellNix.overlay ];
            inherit system;
          };
        in import ./project.nix {
          inherit system;
          inherit pkgs;
          inherit (pkgs) haskell-nix;
          inherit src;
          inherit indexState;

        };
    in flake-utils.lib.eachSystem supportedSystems perSystem;
}
