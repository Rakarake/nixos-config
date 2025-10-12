{ inputs, pkgs, ... }:
{
  #xdg.configFile."grompt/config.toml".source = ./config.toml;
  #home.packages = [ inputs.grompt.defaultPackage."${pkgs.system}" ];
}
