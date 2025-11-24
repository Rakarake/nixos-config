{ pkgs, config, lib, ... }:
let 
  # Matrix livekit file
  keyFile = "/run/livekit.key";
in
{
  # Synapse
  services.postgresql.enable = true;
  services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
    CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
    CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
      TEMPLATE template0
      LC_COLLATE = "C"
      LC_CTYPE = "C";
  '';

  services.matrix-synapse = {
    enable = true;
    settings = with config.services.coturn; {
      server_name = "chat.mdf.farm";
      # This is required for our custom ".wellknown"!
      serve_server_wellknown = false;
      registration_shared_secret_path = config.age.secrets.hotfreddy.path;
      auto_join_rooms = [
        "#playwhen:chat.mdf.farm"
        "#sunkencolumns:chat.mdf.farm"
        "#Reincarnated-as-a-Monke:chat.mdf.farm"
        "#NOMEMES:chat.mdf.farm"
        "#deadlocking:chat.mdf.farm"
        "#animebrainrot:chat.mdf.farm"
        "#monkeshipping:chat.mdf.farm"
        "#Hacking:chat.mdf.farm"
        "#CoC:chat.mdf.farm"
        "#lore:chat.mdf.farm"
        "#bnnuy:chat.mdf.farm"
        "#monsterhunter:chat.mdf.farm"
        "#atlyss:chat.mdf.farm"
      ];

      turn_uris = [
        "turn:${realm}:3478?transport=udp"
        "turn:${realm}:3478?transport=tcp"
      ];
      turn_shared_secret_path = config.age.secrets.freakyfoxy.path;
      turn_user_lifetime = "1h";

      listeners = [
        {
          port = ports.synapse;
          bind_addresses = [ "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
              ];
              compress = false;
            }
          ];
        }
      ];

      # Required for element call
      experimental_features = {
        # MSC3266: Room summary API. Used for knocking over federation
        msc3266_enabled = true;
        # MSC4222 needed for syncv2 state_after. This allow clients to
        # correctly track the state of the room.
        msc4222_enabled = true;
      };

      # The maximum allowed duration by which sent events can be delayed, as
      # per MSC4140.
      max_event_delay_duration = "24h";

      rc_message = {
        # This needs to match at least e2ee key sharing frequency plus a bit of headroom
        # Note key sharing events are bursty
        per_second = 0.5;
        burst_count = 30;
      };
      
      rc_delayed_event_mgmt = {
        # This needs to match at least the heart-beat frequency plus a bit of headroom
        # Currently the heart-beat is every 5 seconds which translates into a rate of 0.2s
        per_second = 1;
        burst_count = 20;
      };
    };
  };
  # Used for matrix-call?
  services.livekit = {
    enable = true;
    openFirewall = true;
    settings.room.auto_create = false;
    inherit keyFile;
  };
  services.lk-jwt-service = {
    enable = true;
    # can be on the same virtualHost as synapse
    livekitUrl = "wss://chat.mdf.farm/livekit/sfu";
    inherit keyFile;
  };
  # generate the key when needed
  systemd.services.livekit-key = {
    before = [
      "lk-jwt-service.service"
      "livekit.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [
      livekit
      coreutils
      gawk
    ];
    script = ''
      echo "Key missing, generating key"
      echo "lk-jwt-service: $(livekit-server generate-keys | tail -1 | awk '{print $3}')" > "${keyFile}"
    '';
    serviceConfig.Type = "oneshot";
    unitConfig.ConditionPathExists = "!${keyFile}";
  };
  # restrict access to livekit room creation to a homeserver
  systemd.services.lk-jwt-service.environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = "chat.mdf.farm";

  services.nginx.virtualHosts."chat.mdf.farm".locations = {
    "/.well-known/matrix/client" = {
      extraConfig = "add_header Content-Type application/json;";
      return = ''200 '{"m.homeserver": {"base_url": "https://chat.mdf.farm"}, "m.identity_server": {"base_url": "https://vector.im"},"org.matrix.msc3575.proxy": {"url": "https://chat.mdf.farm"},"org.matrix.msc4143.rtc_foci": [{"type": "livekit",    "livekit_service_url": "https://chat.mdf.farm/livekit/jwt"}]}      ' '';
    };
    "^~ /livekit/jwt/" = {
      priority = 400;
      proxyPass = "http://[::1]:${toString config.services.lk-jwt-service.port}/";
    };
    "^~ /livekit/sfu/" = {
      extraConfig = ''
        proxy_send_timeout 120;
        proxy_read_timeout 120;
        proxy_buffering off;

        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
      priority = 400;
      proxyPass = "http://[::1]:${toString config.services.livekit.settings.port}/";
      proxyWebsockets = true;
    };
  };

  services.coturn = rec {
    enable = true;
    no-cli = true;
    no-tcp-relay = true;
    min-port = 49000;
    max-port = 50000;
    use-auth-secret = true;
    static-auth-secret-file = config.age.secrets.freakyfoxy.path;
    realm = "voip.mdf.farm";
    cert = "${config.security.acme.certs.${realm}.directory}/full.pem";
    pkey = "${config.security.acme.certs.${realm}.directory}/key.pem";
    extraConfig = ''
      # for debugging
      verbose
      # ban private IP ranges
      no-multicast-peers
      denied-peer-ip=0.0.0.0-0.255.255.255
      denied-peer-ip=10.0.0.0-10.255.255.255
      denied-peer-ip=100.64.0.0-100.127.255.255
      denied-peer-ip=127.0.0.0-127.255.255.255
      denied-peer-ip=169.254.0.0-169.254.255.255
      denied-peer-ip=172.16.0.0-172.31.255.255
      denied-peer-ip=192.0.0.0-192.0.0.255
      denied-peer-ip=192.0.2.0-192.0.2.255
      denied-peer-ip=192.88.99.0-192.88.99.255
      denied-peer-ip=192.168.0.0-192.168.255.255
      denied-peer-ip=198.18.0.0-198.19.255.255
      denied-peer-ip=198.51.100.0-198.51.100.255
      denied-peer-ip=203.0.113.0-203.0.113.255
      denied-peer-ip=240.0.0.0-255.255.255.255
      denied-peer-ip=::1
      denied-peer-ip=64:ff9b::-64:ff9b::ffff:ffff
      denied-peer-ip=::ffff:0.0.0.0-::ffff:255.255.255.255
      denied-peer-ip=100::-100::ffff:ffff:ffff:ffff
      denied-peer-ip=2001::-2001:1ff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=2002::-2002:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fc00::-fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
      denied-peer-ip=fe80::-febf:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    '';
  };

  security.acme.certs = {
    "voip.mdf.farm" = {
      group = "turnserver";
      postRun = "systemctl reload nginx.service; systemctl restart coturn.service";
    };
  };

  # not synapse lol
  age.identityPaths = [
    "/home/rakarake/.ssh/id_ed25519"
    "/home/magarnicle/.ssh/id_ed25519"
  ];
  age.secrets.hotfreddy = {
    file = ../../secrets/hotfreddy.age;
    owner = "matrix-synapse";
    group = "matrix-synapse";
  };
  age.secrets.freakyfoxy = {
    file = ../../secrets/freakyfoxy.age;
    mode = "770";
    owner = "turnserver";
    group = "turnserver";
  };

  # Proxy, enable https etc
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      # Coturn
      "voip.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        #locations."/".root = "/var/www/test";
        #locations."/" = {
        #  proxyWebsockets = true;
        #  proxyPass = "http://localhost";
        #};
      };
      # Matrix
      "chat.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        locations."/" = {
          proxyWebsockets = true;
          proxyPass = "http://localhost:${toString ports.synapse}";
        };
      };
      # Element, matrix frontend
      "element.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        locations."/" = {
          root = pkgs.element-web;
        };
      };
    };
  };

}
