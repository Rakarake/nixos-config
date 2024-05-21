{ pkgs, ... }: {
  amogus = pkgs.callPackage ./amogus { };
  yuzu = pkgs.callPackage ./yuzu { };
  simple-shell-utils = pkgs.callPackage ./simple-shell-utils { };
  bbuilder = pkgs.callPackage ./bbuilder { };
}
