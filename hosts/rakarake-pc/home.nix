# Specific Home Manager options for desktop PC
# NOTE: when overriding dconf settings, think about that
# '//' is not recursive.
{ ... }: 
{
  #dconf.settings = default.dconf.settings // {
  #  "org/gnome/desktop/session" = {
  #    idle-delay = 0;
  #  };
  #};
}

