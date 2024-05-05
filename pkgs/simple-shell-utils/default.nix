{ stdenv }:
stdenv.mkDerivation {
  name = "simple-shell-utils";
  src = ./.;
  installPhase = ''
    mkdir -p $out/bin
    cp $(ls --ignore=default.nix) $out/bin
    chmod -R +x $out/bin
  '';
}

