# Function that given the arguments gives a path to a directory which can be linked
# to with say xdg.configFile.<file>.source that lives inside the git repo.
# All those files created by home manager will be symlinks to the git repo.
# Hardcodes the path of the users nixos-config git repo.
# "location" is which directory will be linked in the git repo.
{ pkgs, user, location }:
let
  path = pkgs.lib.escapeShellArg "/home/${user}/Projects/nixos-config/home/${user}/${location}";
in
  pkgs.runCommandLocal "nixos-mutable-file-${builtins.baseNameOf path}" { }
    "ln -s ${path} $out"

