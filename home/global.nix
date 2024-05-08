# Common among home-manager systems
{ inputs, ... }: {
  imports = [
    inputs.nix-index-database.hmModules.nix-index
    # Enable to use development environment
    inputs.dev-stuff.homeManagerModules.default
  ];
}
