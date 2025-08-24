# Slightly different from the one in nixpkgs, takes a path instead of
# text directly.
{ pkgs, name, runtimeInputs, src }:
  let
    runtimeInputsPathString = builtins.foldl' (acc: dep: acc + "${dep}/bin:") "" runtimeInputs;
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
    src = src;
    installPhase = ''
      mkdir -p $out/bin
      # Put the source file in $out instead of $out/bin
      install -m 755 ${name}.sh $out/${name}.sh
      # Create the wrapper script
      echo "${wrapperText}" > $out/bin/${name}
      chmod 755 $out/bin/${name}
    '';
  }
