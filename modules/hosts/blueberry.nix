# Desktop PC
{ inputs, self, ... }: {
  flake.nixosConfigurations.blueberry = inputs.nixpkgs-unstable.lib.nixosSystem {
  };
}

