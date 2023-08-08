{ pkgs ? import <nixpkgs> { } }:
with pkgs; mkShell {
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [

  ];
}

