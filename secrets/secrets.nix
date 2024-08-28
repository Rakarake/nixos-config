let
  users = import ../ssh-keys.nix;
  keys = users.rakarake ++ users.magarnicle;
in
{
  "monero-rpc-login.age".publicKeys = keys;
}
