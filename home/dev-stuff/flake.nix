{
  description = "Rakarake's dev environment/stuff";
  inputs = {
    # Use nixos-unstable as nixpkgs source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, ... }: {
    homeManagerModules.default = import ./hm-module.nix self;
  };
}

