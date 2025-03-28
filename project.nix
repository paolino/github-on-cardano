{ system, indexState, src, haskell-nix, ... }:
let
  shell = { pkgs, ... }: {
    tools = {
      cabal = { index-state = indexState; };
      cabal-fmt = { index-state = indexState; };
      haskell-language-server = { index-state = indexState; };
      hoogle = { index-state = indexState; };
      fourmolu = { index-state = indexState; };
      hlint = { index-state = indexState; };
      ghcid = { index-state = indexState; };
    };
    withHoogle = true;
    buildInputs = [
      pkgs.gitAndTools.git
    ];
    shellHook = ''
      echo "Entering shell for github-on-cardano project"
    '';
  };

  mkProject = ctx@{ lib, pkgs, ... }: {
    name = "github-on-cardano";
    compiler-nix-name = "ghc966";
    inherit src;
    shell = shell { inherit pkgs; };
    modules = [ ];

  };
  project = haskell-nix.cabalProject' mkProject;
  packages = let components = project.hsPkgs.github-on-cardano.components;
  in {
    inherit project;
    github-on-cardano = components.exes.github-on-cardano;
    github-on-cardano-tests = components.tests.github-on-cardano-test;
  };
in {
  inherit packages;
  devShell = project.shell;
}
