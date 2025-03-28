# shellcheck shell=bash

version := "0.1.0.0"
# Format code with nixfmt and fourmolu and cabal-fmt
format:
  find . -name '*.nix' -exec nixfmt {} +
  # shellcheck disable=SC2046
  fourmolu --mode inplace $(find . -name '*.hs')
  # shellcheck disable=SC2046
  cabal-fmt --inplace $(find . -name '*.cabal')

docker-image:
  nix bundle --bundler github:NixOS/bundlers#toDockerImage .#github-on-cardano
  docker load -i github-on-cardano-exe-github-on-cardano-0.1.0.0.tar.gz

docker-up:
  docker compose up -d

bundle-github-on-cardano:
    rm -f github-on-cardano
    nix bundle .#github-on-cardano
    cp -L github-on-cardano-exe-github-on-cardano-arx github-on-cardano
    rm github-on-cardano-exe-github-on-cardano-arx

cachix:
    nix build .#github-on-cardano
    cachix push paolino ./result
    nix build .#github-on-cardano-tests
    cachix push paolino ./result
    nix bundle .#github-on-cardano
    cachix push paolino ./github-on-cardano-exe-github-on-cardano-arx
    nix bundle --bundler github:NixOS/bundlers#toDockerImage .#github-on-cardano
    # shellcheck disable=SC1083
    cachix push paolino ./github-on-cardano-exe-github-on-cardano-{{version}}.tar.gz

cachix-parallel:
    ( nix build .#github-on-cardano -o github-on-cardano && \
        cachix push paolino ./github-on-cardano)&
    ( nix build .#github-on-cardano-testing-client -o github-on-cardano-testing-client && \
        cachix push paolino ./github-on-cardano-testing-client)&
    ( nix build .#github-on-cardano-tests -o github-on-cardano-tests&& \
        cachix push paolino ./github-on-cardano-tests)&
    ( nix bundle .#github-on-cardano && \
        cachix push paolino ./github-on-cardano-exe-github-on-cardano-arx)&
    # shellcheck disable=SC1083
    ( nix bundle --bundler github:NixOS/bundlers#toDockerImage .#github-on-cardano && \
        cachix push paolino ./github-on-cardano-exe-github-on-cardano-{{version}}.tar.gz)&
