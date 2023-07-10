{
  description = "A super system configuration";
  inputs = {
    nix-software-center.url = "github:vlinkz/nix-software-center";
  };
  outputs = { self, nixpkgs, ... }@attrs: {
    nixosConfigurations.rakarake-thinkpad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [ ./configuration.nix ];
    };
  };
}
