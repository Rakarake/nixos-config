<img src="logo.png" width=25% height=25%>

# NEW STRUCTURE
- The usage of flake-parts and nix-tree.

# NixOS Config
This cool nixos system config uses flakes.

`nix build .#nixosConfigurations.live.config.system.build.isoImage` to
build a live ISO image. TODO reintroduce this.

`nix-shell` to bootstrap, enable flakes etc.

`sudo nixos-rebuild switch --flake '.#hostname'` to rebuild system with the right hostname.
After this, `sudo nixos-rebuild switch --flake .` can be used instead.

`nix flake update` to update, requires rebuild to apply.

`nix flake lock --update-input dev-stuff` to update flake input 'dev-stuff'.

For garbage collection: use nh since it can clean direnv profiles (e.g. `nh clean all`), or
just use the collect-garbage (graphical sessions only).

`nix-store --optimize` to link derivations with the same content, saving space.

`sudo nix-env --list-generations --profile /nix/var/nix/profiles/system` to
list your generations.

## Minecraft Servers
`sudo -u <service-user> tmux -S /var/<name-of-server>/tmux.socket attach` to to enter the server console.

if that doesn't work then try:
`sudo -u SERVERUSER tmux -S /PATH/TO/SOCKET/tmux.socket attach -d`

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

