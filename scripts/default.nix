# Little bit of boilerplate reduction.
pkgs: 
let
  # Slightly different from the one in nixpkgs, takes a path instead of
  # text directly.
  writeShellApplicationWithArguments = { name, runtimeInputs, path }:
  let
    runtimeInputsPathString = builtins.foldl' (acc: dep: acc + "${dep}:") "" runtimeInputs;
    wrapperText = ''#!${pkgs.bash}/bin/bash
set -o errexit
set -o nounset
set -o pipefail
export PATH=\"${runtimeInputsPathString}\$PATH\"
$out/${name}.sh \"\$@\"
'';
  in
  pkgs.stdenv.mkDerivation
  {
    name = name;
    buildInputs = runtimeInputs;
    src = ./.;
    installPhase = ''
      mkdir -p $out/bin
      # Put the source file in $out instead of $out/bin
      install -m 755 ${name}.sh $out/${name}.sh
      # Create the wrapper script
      echo "${wrapperText}" > $out/bin/${name}
      chmod 755 $out/bin/${name}
    '';
  };
in
((builtins.mapAttrs (name: value: writeShellApplicationWithArguments {
  name = name;
  runtimeInputs = value;
  path = ./${name}.sh;
}))

# All scripts and their dependencies needs to be specified here.
(with pkgs; {
  rootful = [ xwayland openbox ];
  etyp = [ typst xdg-utils ];
  nix-goto = [ ];
  ns = [ nix ];
  update = [ nix nh flatpak ];
  open-file-in-clipboard = [ xdg-utils wl-clipboard ];
}))

