# shellcheck shell=bash disable=SC2046 disable=SC1083

package := "github-on-cardano"
cachix-repo := "paolino"
version := "0.1.0.0"
# Format code with nixfmt and fourmolu and cabal-fmt
format:
  find . -name '*.nix' -exec nixfmt {} +
  fourmolu --mode inplace $(find . -name '*.hs')
  cabal-fmt --inplace $(find . -name '*.cabal')

docker-image:
  nix bundle --bundler github:NixOS/bundlers#toDockerImage .#{{package}}
  docker load -i {{package}}-exe-{{package}}-0.1.0.0.tar.gz

docker-up:
  docker compose up -d

bundle:
    rm -f {{package}}
    nix bundle .#{{package}}
    cp -L {{package}}-exe-{{package}}-arx {{package}}
    rm {{package}}-exe-{{package}}-arx

cachix:
    nix build .#{{package}}
    cachix push {{cachix-repo}} ./result
    nix build .#{{package}}-tests
    cachix push {{cachix-repo}} ./result
    nix bundle .#{{package}}
    cachix push {{cachix-repo}} ./{{package}}-exe-{{package}}-arx
    nix bundle --bundler github:NixOS/bundlers#toDockerImage .#{{package}}
    cachix push {{cachix-repo}} ./{{package}}-exe-{{package}}-{{version}}.tar.gz

cachix-parallel:
    ( nix build .#{{package}} -o {{package}} && \
        cachix push {{cachix-repo}} ./{{package}})&
    ( nix build .#{{package}}-testing-client -o {{package}}-testing-client && \
        cachix push {{cachix-repo}} ./{{package}}-testing-client)&
    ( nix build .#{{package}}-tests -o {{package}}-tests&& \
        cachix push {{cachix-repo}} ./{{package}}-tests)&
    ( nix bundle .#{{package}} && \
        cachix push {{cachix-repo}} ./{{package}}-exe-{{package}}-arx)&
    ( nix bundle --bundler github:NixOS/bundlers#toDockerImage .#{{package}} && \
        cachix push {{cachix-repo}} ./{{package}}-exe-{{package}}-{{version}}.tar.gz)&
