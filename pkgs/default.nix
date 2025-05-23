{ pkgs, ... }: {
  amogus = pkgs.callPackage ./amogus { };
  simple-shell-utils = pkgs.callPackage ./simple-shell-utils { };
  etyp = pkgs.callPackage ./etyp.nix { };
}
