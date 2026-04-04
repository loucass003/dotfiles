{
  config,
  pkgs,
  lib,
  ...
}:

let
  vaultPath = "/home/llelievr/Obsidian";
  syncInterval = "5m";
  remoteUrl = "https://fileshare.llelievr.dev";
  remotePath = "/media/ObsidianVaults/";

  mkSyncScript = cmd: extraArgs: pkgs.writeShellScript "obsidian-sync" ''
    set -e
    USER=$(cat ${config.sops.secrets."webdav/username".path})
    PASS=$(${pkgs.rclone}/bin/rclone obscure "$(cat ${config.sops.secrets."webdav/password".path})")
    CF_ID=$(cat ${config.sops.secrets."cloudflare_zerotrust/cf_client_id".path})
    CF_SECRET=$(cat ${config.sops.secrets."cloudflare_zerotrust/cf_client_secret".path})
    exec ${pkgs.rclone}/bin/rclone ${cmd} \
      --webdav-url=${remoteUrl} \
      --webdav-vendor=generic \
      --webdav-user="$USER" \
      --webdav-pass="$PASS" \
      --header="CF-Access-Client-Id: $CF_ID" \
      --header="CF-Access-Client-Secret: $CF_SECRET" \
      --fast-list --transfers=4 --create-empty-src-dirs \
      ${extraArgs}
  '';
in
{
  environment.systemPackages = with pkgs; [
    rclone
  ];

  # Secrets must be readable by llelievr for user services
  sops.secrets."webdav/username" = {
    sopsFile = ../secrets/webdav.yaml;
    owner = "llelievr";
  };

  sops.secrets."webdav/password" = {
    sopsFile = ../secrets/webdav.yaml;
    owner = "llelievr";
  };

  sops.secrets."cloudflare_zerotrust/cf_client_id" = {
    sopsFile = ../secrets/cf.yaml;
    owner = "llelievr";
  };

  sops.secrets."cloudflare_zerotrust/cf_client_secret" = {
    sopsFile = ../secrets/cf.yaml;
    owner = "llelievr";
  };

  # Create vault directory
  systemd.tmpfiles.rules = [
    "d '${vaultPath}' 0755 llelievr users - -"
  ];

  # Pull from NAS
  systemd.user.services.obsidian-sync-pull = {
    description = "Pull Obsidian vault from WebDAV NAS";
    after = [ "network-online.target" ];
    wantedBy = [ "default.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mkSyncScript "copy" "--update :webdav:${remotePath} ${vaultPath}"}";
      StandardError = "journal";
      StandardOutput = "journal";
    };
  };

  # Timer to pull regularly
  systemd.user.timers.obsidian-sync-pull = {
    description = "Run Obsidian vault pull sync periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = syncInterval;
      Persistent = true;
    };
  };

  # Timer to push regularly
  systemd.user.timers.obsidian-sync-push = {
    description = "Run Obsidian vault push sync periodically";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = syncInterval;
      Persistent = true;
    };
  };

  # Push on interval
  systemd.user.services.obsidian-sync-push = {
    description = "Push Obsidian vault changes to WebDAV NAS";
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mkSyncScript "sync" "${vaultPath} :webdav:${remotePath}"}";
      StandardError = "journal";
      StandardOutput = "journal";
    };
  };

  # Push before sleep
  systemd.user.services.obsidian-sync-push-sleep = {
    description = "Push Obsidian vault changes before sleep";
    before = [ "sleep.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mkSyncScript "sync" "${vaultPath} :webdav:${remotePath}"}";
      StandardError = "journal";
      StandardOutput = "journal";
      TimeoutStartSec = "infinity";
    };
  };

  # Push on shutdown
  systemd.user.services.obsidian-sync-push-shutdown = {
    description = "Push Obsidian vault changes on shutdown";
    before = [ "shutdown.target" ];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${mkSyncScript "sync" "${vaultPath} :webdav:${remotePath}"}";
      StandardError = "journal";
      StandardOutput = "journal";
      TimeoutStartSec = "infinity";
    };
  };
}
