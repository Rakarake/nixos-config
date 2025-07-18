<img src="logo.png" width=25% height=25%>

# NixOS Config
This cool nixos system config uses flakes.

`nix build .#nixosConfigurations.live.config.system.build.isoImage` to
build a live ISO image.

`nix-shell` to bootstrap, enable flakes etc.

`sudo nixos-rebuild switch --flake '.#hostname'` to rebuild system with the right hostname.
After this, `sudo nixos-rebuild switch --flake .` can be used instead.

`home-manager switch --flake '.#<user>/<hostname>-<variation>'` to initiate home-manager.
Currently, home configurations can be specified to have versions, usually
dark/light versions (default for "I don't care"). Look at flake.nix how this
is configured.

`nix flake update` to update, requires rebuild to apply.

`nix flake lock --update-input dev-stuff` to update flake input 'dev-stuff'.

`nix-collect-garbage --delete-older-than 10d` to clean the nix store.
NOTE: run as root to remove old system packages and boot entries.

`nix-store --optimize` to link derivations with the same content, saving space.

`sudo nix-collect-garbage -d` then *rebuild* to remove bootloader entries.

`sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` to
list your generations.

`nix-channel --add https://nixos.org/channels/nixos-unstable nixos` to
set the 'package channel' to nixos-unstable (not system config).

`nix-channel --update` to update the channel.

## Minecraft Servers
`tmux -S /var/<name-of-server>/tmux.socket attach` to to enter the server console
### Initial MC server setup "guide" - am writing this from the top of my head. Might therefore be somewhat incomplete.
1. Setup the MC directories
2. Manually download server.jar
3. Run the server manually once (`java -Xmx1024M -Xms1024M -jar minecraft_server.1.21.8.jar nogui`)
4. Set True in the eula.jar or .txt or whatever it is
5. Configure the server.config: set correct ports and difficulty etc.
6. I think chown is next for the MC server user
7. Set up the config in the git
8. Pull and rebuild (🙏🙏🙏)


## Troubleshooting
### When switching from Plasma to Gnome
Remove stuff left by KDE with `rm -r .config/gtk-3.0/ ~/.gtkrc-2.0 ~/.config/dconf/ ~/.gtkrc-2.0`.
Load the dconf settings after removing the files by doing a rebuild.
These paths could be wrong, please fix if the case.

