# NixOS Config
This cool nixos system config uses flakes.

`nix-shell` to bootstrap.

`sudo nix flake update` to update.

`sudo nixos-rebuild switch --flakes .` to apply configuration.
`rebuild` to apply configuration when using configuration.

`nix-collect-garbage --delete-older-than 30d` to clean the nix store.

`sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 30d`
to remove bootloader entries.

`nix-channel --add https://nixos.org/channels/nixos-unstable nixos` to
set the 'package channel' to nixos-unstable (not system config).

`nix-channel --update` to update the channel.

