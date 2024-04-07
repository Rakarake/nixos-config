# NixOS Config
This cool nixos system config uses flakes.

`nix build .#nixosConfigurations.live.config.system.build.isoImage` to
build a live ISO image.

`nix-shell` to bootstrap, enable flakes etc.

`sudo nixos-rebuild switch --flake '.#hostname'` to rebuild system with the right hostname.

`home-manager switch --flake .` to initiate home-manager, in order to get aliases etc
(after that `hmrebuild` can be used).

`sudo nixos-rebuild switch --flake .` to apply configuration.
`rebuild` to apply configuration when using configuration.

`nix flake update` to update, requires rebuild to apply.

`nix flake lock --update-input dev-stuff` to update flake input 'dev-stuff'.

`nix-collect-garbage --delete-older-than 10d` to clean the nix store.

`sudo nix-env --delete-generations --profile /nix/var/nix/profiles/system 10d`
to remove bootloader entries.

`sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` to
list your generations.

`nix-channel --add https://nixos.org/channels/nixos-unstable nixos` to
set the 'package channel' to nixos-unstable (not system config).

`nix-channel --update` to update the channel.

A file containing the names of the system's "packages" can be found after
rebuild at `/etc/current-system-packages`.

## New configurations
Remember to include `modules/default.nix` (makes options available) and `modules/global.nix`
(important global options).

## Troubleshooting
### When switching from Plasma to Gnome
Remove stuff left by KDE with `rm -r .config/gtk-3.0/ ~/.gtkrc-2.0 ~/.config/dconf/ ~/.gtkrc-2.0`.
Load the dconf settings after removing the files by doing a rebuild.
These paths could be wrong, please fix if the case.

