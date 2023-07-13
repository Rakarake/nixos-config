# Thinkpad Specific settings
{ config, pkgs, ... }@attrs:
{
  networking.hostName = "rakarake-thinkpad";  # Define your hostname.
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
}
