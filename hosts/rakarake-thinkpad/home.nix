{ lib, config, pkgs, ... }@attrs: 
let
  default = (import ../../home.nix) attrs;
  gnome = (import ../../home-gnome.nix) attrs;

in
default // gnome // {
}
