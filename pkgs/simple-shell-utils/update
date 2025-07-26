#!/bin/sh
# Script for updating everything.
# Does a system rebuild, a home manager rebuild, flatpak update and garbage collects the nix store
# without removing direnv artifacts.
# Also does a nix-store --optimize.
# Can provide 'stealthy' as third argument to not do a nix flake update.

if ! ([ "$1" = "push" ] || [ "$1" = "pull" ]);
    then echo "argument 1: wether to push/pull, is needed"; exit 1;
fi
if ! ([ "$2" = "light" ] || [ "$2" = "dark" ] || [ "$2" = "" ]);
    then echo "illegal argument 2: variation light/dark or no second argument allowed"; exit 1;
fi

cd ~/Projects/nixos-config \
&& git pull \
&& if [ "$1" = "push" ] && ! [ "$3" = "stealthy" ]; then nix flake update; fi \
&& if [ "$2" == "" ]; then nh home switch -c $USER@$HOSTNAME .;
                      else nh home switch -c $USER@$HOSTNAME-$2 .;
fi \
&& flatpak update -y \
&& nh os switch . \
&& nh clean all -k 3 -K 14d \
&& nix-store --optimize \
&& if [ "$1" = "push" ]; then {
     git add flake.lock \
     && git commit -m 'flake update' \
     && git push
   } fi

