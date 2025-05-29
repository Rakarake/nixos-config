let
  users = import ../ssh-keys.nix;
  keys = users.rakarake ++ users.magarnicle;
in
{
  "monero-rpc-login.age".publicKeys = keys;
  "nextcloud-whiteboard-secret.age".publicKeys = keys;
  "matrix-synapse-secret-config.age".publicKeys = keys;
}
