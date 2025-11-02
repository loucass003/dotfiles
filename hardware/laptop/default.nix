# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  hostname,
  pkgs,
  lib,
  modulesPath,
  ...
}:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../config-commons.nix
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [
    "amdgpu"
    "v4l2loopback"
  ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cdf89972-05d7-4462-a336-36fecc37e946";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C682-FA68";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];
    # desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  hardware.graphics = {
    ## radv: an open-source Vulkan driver from freedesktop
    enable32Bit = true;
  };

  boot.kernelParams = [
    # ugreen dock
    "usbcore.autosuspend=-1"
    "usbcore.quirks=3188:5335:k"
  ];
  boot.extraModprobeConfig = ''
    # Quirk for UGREEN dock - ignore power requirements
    options usbcore quirks=3188:5335:k

    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1

    options quirks=0x100 trace=1
  '';

  services.udev.extraRules = ''
    # UGREEN Dock - disable power checking
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3188", ATTR{idProduct}=="5335", RUN+="${pkgs.bash}/bin/bash -c 'echo -1 > /sys/module/usbcore/parameters/autosuspend'"

    # UGREEN Dock - For all devices on Bus 5, bypass power checks
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{busnum}=="5", ATTR{bConfigurationValue}="1"
  '';

  boot.loader.grub.configurationLimit = 40;

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
  networking.enableIPv6 = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
