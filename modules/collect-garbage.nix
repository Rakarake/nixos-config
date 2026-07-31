{ inputs, ... }: {
  perSystem = { system, ... }: let
    pkgs = import inputs.nixpkgs-unstable { inherit system; };
  in {
    packages.collect-garbage = pkgs.writeShellScriptBin "collect-garbage" ''
      pkexec nh clean all -K 7d \
      && nix-store --optimize \
      && notify-send "Done collecting garbage."
    '';
  };
}

