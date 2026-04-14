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
  # Weekly script containing secrets
  "weekly-notice.age".publicKeys = keys;
  # MDF website http basic auth logins, use `htpasswd .htpasswd User` use -c
  # to create new file.
  "mdf-login.age".publicKeys = keys;
  # Nextcloud webdav login
  "rakarake-rclone-webdav.age".publicKeys = keys;
}
