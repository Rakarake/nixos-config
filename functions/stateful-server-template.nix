# Returns a nixos module when provided with it's arguments.
# Provides a tmux session for servers like minecraft where you can interact
# with them. When connecting you need to be the same user as the service.
# Must provide name and description for the systemd unit.
# Can provide extra packages that will be put in path.
# What will be run is the script in 'path' named 'start.sh'.
# Everything needs to be set up, with the right permissions and everything
# before this service will work.
# Does not open ports.
{ name, description ? "${name} server", path ? /var/${name}, packages ? [], }:
{ pkgs, ... }:
{
  systemd.services.${name} = {
    enable = true;
    path = [ pkgs.coreutils pkgs.tmux pkgs.bash pkgs.ncurses ] ++ packages;
    wantedBy = [ "multi-user.target" ]; 
    after = [ "network.target" ];
    description = description;
    serviceConfig = {
      User = name;
      ExecStart = "${pkgs.tmux}/bin/tmux -S tmux.socket new-session -d -s ${name} /bin/sh start.sh";
      ExecStop = "${pkgs.tmux}/bin/tmux -S tmux.socket kill-session -t ${name}";
      Type = "forking";
      Restart = "on-failure";
      WorkingDirectory = path;
    };
  };
  users = {
    groups.${name} = {};
    users.${name} = {
      isSystemUser = true;
      description = description;
      group = name;
    };
  };
}

