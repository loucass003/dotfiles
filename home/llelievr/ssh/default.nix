{
  config,
  pkgs,
  ...
}:

let
  secrets = import ../secrets;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        identityFile = "${secrets.ssh.main_key.private}";
      };
    };
  };
}
