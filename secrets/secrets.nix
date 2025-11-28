let
  users = import ../ssh-keys.nix;
  keys = users.rakarake ++ users.magarnicle;
in
{
  "monero-rpc-login.age".publicKeys = keys;
  "nextcloud-whiteboard-secret.age".publicKeys = keys;
  # Matrix synapse regstration token
  "hotfreddy.age".publicKeys = keys;
  # Coturn static auth secret
  "freakyfoxy.age".publicKeys = keys;
  # Discord bot auth token
  "smojitroppy.age".publicKeys = keys;
  # Smojitroppy client secret
  "smojitroppy-client.age".publicKeys = keys;
}
