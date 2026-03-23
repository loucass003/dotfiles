{ config, ... }:

let
  serverUrl = "https://fileshare.llelievr.dev";
  mountPoint = "/mnt/nas";
in
{
  sops.secrets."webdav/username" = {
    sopsFile = ../secrets/webdav.yaml;
  };

  sops.secrets."webdav/password" = {
    sopsFile = ../secrets/webdav.yaml;
  };

  sops.secrets."cloudflare_zerotrust/cf_client_id" = {
    sopsFile = ../secrets/cf.yaml;
  };

  sops.secrets."cloudflare_zerotrust/cf_client_secret" = {
    sopsFile = ../secrets/cf.yaml;
  };

  sops.templates."davfs2-config" = {
    content = ''
      add_header CF-Access-Client-Id ${config.sops.placeholder."cloudflare_zerotrust/cf_client_id"}
      add_header CF-Access-Client-Secret ${
        config.sops.placeholder."cloudflare_zerotrust/cf_client_secret"
      }
    '';
    path = "/etc/davfs2/davfs2.conf";
    mode = "0600";
    owner = "root";
    group = "root";
  };

  sops.templates."davfs2-secrets" = {
    content = ''
      ${serverUrl} ${config.sops.placeholder."webdav/username"} ${
        config.sops.placeholder."webdav/password"
      }
    '';
    path = "/etc/davfs2/secrets";
    mode = "0600";
    owner = "root";
    group = "root";
  };

  services.davfs2.enable = true;

  fileSystems."${mountPoint}" = {
    device = serverUrl;
    fsType = "davfs";
    options = [
      "_netdev"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=300"
      "uid=1000"
      "gid=100" # users group
    ];
  };
}
