# This configuration uses the built-in turn server in livekit to get
# element-call to work.

{ pkgs, config, lib, inputs, pkgs-unstable, ... }:
let 
  # Matrix livekit file
  keyFile = "/run/livekit.key";
  synapsePort = 8008;
  turnSecret = "depressedfoxy";
  wellKnownClient = {
    "m.homeserver" = { "base_url" = "https://chat.mdf.farm"; };
    "org.matrix.msc4143.rtc_foci" = [
      {
        "type" = "livekit"; "livekit_service_url" = "https://voip.mdf.farm/jwt";
      }
    ];
  };
  wellKnownServer = {
    "m.server" = "chat.mdf.farm:443";
  };
  mkWellKnown = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;

    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    add_header Access-Control-Allow-Headers "X-Requested-With, Content-Type, Authorization";

    return 200 '${builtins.toJSON data}';
  '';
in
{
  imports = [
    inputs.out-of-your-element.modules.default
  ];
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
    settings = {
      server_name = "chat.mdf.farm";
      max_upload_size = "2G";
      # This is required for our custom ".wellknown"!
      serve_server_wellknown = true;
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

      listeners = [
        {
          port = synapsePort;
          bind_addresses = [ "127.0.0.1" "::1" ];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [
                "client"
                "federation"
                "media"
              ];
              compress = false;
            }
          ];
        }
      ];

      # Livekit turn connection
      turn_uris = [
        #"turn:voip.mdf.farm?transport=udp"
        #"turn:voip.mdf.farm?transport=tcp"
        #"turns:voip.mdf.farm?transport=tcp"
        "turns:voip.mdf.farm:${builtins.toString config.services.coturn.tls-listening-port}?transport=udp"
        "turns:voip.mdf.farm:${builtins.toString config.services.coturn.tls-listening-port}?transport=tcp"
        "turn:voip.mdf.farm:${builtins.toString config.services.coturn.listening-port}?transport=udp"
        "turn:voip.mdf.farm:${builtins.toString config.services.coturn.listening-port}?transport=tcp"
      ];
    
      turn_shared_secret = turnSecret;
      turn_user_lifetime = "1h";
      turn_allow_guests = true;

      # Required for element call
      experimental_features = {
        # MSC3266: Room summary API. Used for knocking over federation
        msc3266_enabled = true;
        # MSC4222 needed for syncv2 state_after. This allow clients to
        # correctly track the state of the room.
        msc4222_enabled = true;
        # disable thing for science
        msc3916_authenticated_media_enabled = false; 
        #match msc4140 to matrix.org
        msc4140_enabled = false;
      };

      # The maximum allowed duration by which sent events can be delayed, as
      # per MSC4140.
      # max_event_delay_duration = "24h";

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

  networking.firewall.enable = lib.mkForce false;
  services.coturn = {
    enable = true;
    realm = "voip.mdf.farm";

    listening-ips = [ "0.0.0.0" ];
    listening-port = 3478;
    tls-listening-port = 3480;

    relay-ips = [ "31.210.250.250" ];
    min-port = 49152;
    max-port = 65535;

    cert = "${config.security.acme.certs."voip.mdf.farm".directory}/fullchain.pem";
    pkey = "${config.security.acme.certs."voip.mdf.farm".directory}/key.pem";

    #no-auth = true;
    no-tcp = true;
    secure-stun = true;
    ## lt-cred-mech = true;
    use-auth-secret = true;
    static-auth-secret = turnSecret;

    extraConfig = ''
      no-multicast-peers
      total-quota=50
    '';
  };

  #services.coturn = {
  #  enable = true;
  #
  #  # IMPORTANT: must match your domain
  #  realm = "voip.mdf.farm";

  #  # Use shared secret auth (what Synapse expects)
  #  use-auth-secret = true;
  #  static-auth-secret = turnSecret;
  #
  #  # Networking
  #  listening-port = 3478;
  #  tls-listening-port = 5349;
  #
  #  # Relay ports (VERY IMPORTANT for WebRTC)
  #  min-port = 49000;
  #  max-port = 50000;

  #  cert = "${config.security.acme.certs."voip.mdf.farm".directory}/full.pem";
  #  pkey = "${config.security.acme.certs."voip.mdf.farm".directory}/key.pem";

  #  #no-loopback-peers
  #  
  #  #lt-cred-mech
  #  extraConfig = ''
  #    fingerprint
  #    stale-nonce
  #    no-multicast-peers

  #    no-cli
  #    listening-ip = 0.0.0.0
  #  '';
  #};

  # Used for matrix-call?
  services.livekit = {
    enable = true;
    package = pkgs-unstable.livekit;
    # Requires open ports 50000-51000
    openFirewall = true;
    settings = {
      room.auto_create = false;
      turn = {
        enabled = false; #enabled = true;
        #udp_port = 3478;
        #tls_port = 5349;
        #relay_range_start = 49000;
        #relay_range_end = 50000;
        #domain = "voip.mdf.farm";
        #secret = turnSecret;
      };
    };
    inherit keyFile;
  };
  services.lk-jwt-service = {
    enable = true;
    #port = 8451;
    # can be on the same virtualHost as synapse
    livekitUrl = "wss://voip.mdf.farm/sfu";
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
  services.nginx.virtualHosts."voip.mdf.farm".locations = {
    "^~ /jwt/" = {
      priority = 400;
      proxyPass = "http://localhost:${toString config.services.lk-jwt-service.port}/";
    };
    "^~ /sfu/" = {
      extraConfig = ''
        proxy_send_timeout 120;
        proxy_read_timeout 120;
        proxy_buffering off;

        proxy_redirect off;

        proxy_set_header Accept-Encoding gzip;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
      '';
      priority = 400;
      proxyPass = "http://localhost:${toString config.services.livekit.settings.port}/";
      proxyWebsockets = true;
    };
  };
  services.nginx.virtualHosts."chat.mdf.farm".locations = {
    "= /.well-known/matrix/client" = {
      extraConfig = mkWellKnown wellKnownClient;
      priority = 400;
    };
    "= /.well-known/matrix/server" = {
      extraConfig = mkWellKnown wellKnownServer;
      priority = 400;
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
  age.secrets.smojitroppy = {
    file = ../../secrets/smojitroppy.age;
    mode = "744";
    owner = "root";
    group = "root";
  };
  age.secrets.smojitroppy-client = {
    file = ../../secrets/smojitroppy-client.age;
    mode = "744";
    owner = "root";
    group = "root";
  };
  security.acme.certs."voip.mdf.farm" = {
    #defaults.webroot = "/var/lib/acme/acme-challenge/";
    # We are using nginx as webserver, therefore set correct key permissions
    postRun = "systemctl restart coturn.service";
    group = "turnserver";
  };


  # Proxy, enable https etc
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      # Livekit + livekit's built in TURN server
      "voip.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
      };
      # Matrix
      "chat.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        locations."/" = {
          proxyPass = "http://localhost:${toString synapsePort}";
          proxyWebsockets = true;
      
          extraConfig = ''
            client_max_body_size 2G;

            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
          '';
        };
      };
      # Element, matrix frontend
      "element.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        locations."/" = {
          extraConfig = "
            add_header Access-Control-Allow-Origin *;
          ";
          root = pkgs.element-web;
        };
      };
      "cinny.mdf.farm" = {
        forceSSL = true;
        enableACME = true; # Let's encrypt TLS automated, not certbot
        locations."/" = {
          extraConfig = "
            add_header Access-Control-Allow-Origin *;
          ";
          root = pkgs.cinny;
          #root = let
          #  cinny-unwrapped = pkgs.cinny-unwrapped.overrideAttrs (old: rec {
          #    version = "4.11.1";
          #    src = pkgs.fetchFromGitHub {
          #      owner = "cinnyapp";
          #      repo = "cinny";
          #      tag = "v${version}";
          #      hash = "sha256-dwI3zNey/ukF3t2fhH/ePf4o4iBDwZyLWMYebPgXmWU=";
          #    };
          #    npmDepsHash = lib.fakeHash;
          #  });
          #in pkgs.cinny.override { inherit cinny-unwrapped; };
        };
      };
    };
  };

  nixpkgs.overlays = [ (final: prev: {
    cinny-unwrapped = prev.cinny-unwrapped.overrideAttrs (old: rec {
      version = "4.12.1";
      src = prev.fetchFromGitHub {
        owner = "cinnyapp";
        repo = "cinny";
        tag = "v${version}";
        hash = "sha256-dwI3zNey/ukF3t2fhH/ePf4o4iBDwZyLWMYebPgXmWU=";
      };
      npmDepsHash = "sha256-27WFjb08p09aJRi0S2PvYq3bivEuG5+z2QhFahTSj4Q=";
      npmDeps = prev.fetchNpmDeps {
        inherit src;
        hash = npmDepsHash;
      };
    });
  } ) ];

  services.matrix-ooye = {
    enable = true;
    discordTokenPath = config.age.secrets.smojitroppy.path;
    discordClientSecretPath = config.age.secrets.smojitroppy-client.path;
    homeserverName = "chat.mdf.farm";
    homeserver = "https://chat.mdf.farm";
    enableSynapseIntegration = true;
    appserviceId = "ooye-gleeby-weeby";
  };
}
