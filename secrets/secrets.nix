let
  users = import ../ssh-keys.nix;
  keys = users.rakarake ++ users.magarnicle;
in
{
  "monero-node-password.age".publicKeys = keys;
}
