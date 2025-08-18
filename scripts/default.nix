# Little bit of boilerplate reduction.
pkgs: writeShellApplicationWithArguments: 
((builtins.mapAttrs (name: value: writeShellApplicationWithArguments {
  inherit pkgs;
  name = name;
  runtimeInputs = value;
  src = ./.;
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

