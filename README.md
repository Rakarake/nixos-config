# NixOS Config
This cool nixos system config uses flakes.

`nix-shell` to bootstrap.

`sudo nix flake update` to update.

`sudo nixos-rebuild switch --flakes .` to apply configuration.
`rebuild` to apply configuration when using configuration.

`nix-collect-garbage --delete-older-than 30d` to clean the nix store.

`sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 10d`
to remove bootloader entries.

