# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, hostname, pkgs, ... }:

{

  imports = [
    ../config-commons.nix
    ./hardware.nix
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.llelievr = {
    isNormalUser = true;
    description = "llelievr";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "docker"
      "dialout"
      # "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  networking.firewall.enable = false;
  networking.enableIPv6 = false; #teamviewer hate ipv6 ....

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
