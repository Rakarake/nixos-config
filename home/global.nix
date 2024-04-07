# Common among home-manager systems
{ inputs, ... }: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    # For some reason, this cannot be imported in the hyprland module,
    # I get infinate recursion.
    inputs.hyprland.homeManagerModules.default
    # Enable to use development environment
    inputs.dev-stuff.homeManagerModules.default
  ];
}
