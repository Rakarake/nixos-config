{ lib, pkgs }:
let
  utils = import ./utils.nix;
  createBinSnippet = filename : content : ''printf "${content}" > $out/bin/${filename}'';
in
derivation {
  name = "simple-shell-utils";
  system = pkgs.system;
  builder = "${pkgs.bash}/bin/bash";
  args = [
    "-c"
    ("${pkgs.coreutils-full}/bin/mkdir -p $out/bin\n" +
    (lib.concatStringsSep "\n" (lib.attrValues (lib.mapAttrs createBinSnippet utils))) +
    "\n${pkgs.coreutils-full}/bin/chmod -R +x $out/bin")
  ];
}

#{ lib, pkgs }:
#let
#  utils = import ./utils.nix;
#  createBinSnippet = filename : content : ''printf "${content}" > $out/bin/${filename}'';
#in
#derivation {
#  name = "simple-shell-utils";
#  system = pkgs.system;
#  builder = "${pkgs.bash}/bin/bash";
#  args = [ "-c" "${pkgs.coreutils-full}/bin/mkdir -p $out/bin ; echo hello world > $out/bin/goobagoob" ];
#}


