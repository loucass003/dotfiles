# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  hostname,
  pkgs,
  lib,
  modulesPath,
  pkgs-stable,
  ...
}:

{

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../config-commons.nix
    # ../../nixos/niri
    ../../nixos/hyprland
    ../../nixos/syncthing.nix
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
    "thunderbolt"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "v4l2loopback"
  ];

  services.hardware.bolt.enable = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/cdf89972-05d7-4462-a336-36fecc37e946";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1597-E473";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/f140a6df-ded2-4cdd-ab81-88c290bedf14"; }
  ];

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
    videoDrivers = [
      "amdgpu"
    ];
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.thermald.enable = true;

  hardware.enableRedistributableFirmware = true;

  boot.kernelParams = [
    # This is the "Magic Fix" for the NuPhy/Power limit issue without touching Monitors
    "usbcore.quirks=19f5:32f5:bk,0d8c:0102:bk"
    "usbcore.autosuspend=-1"

    # Thunderbolt eGPU: disable PCIe power state management (D3cold link failures)
    "pcie_port_pm=off"
  ];

  boot.extraModprobeConfig = ''
    # Quirk for UGREEN dock - ignore power requirements
    options usbcore quirks=3188:5335:k

    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1

    options quirks=0x100 trace=1
  '';

  # If you want to keep udev rules, use this modernized version 
  # that targets the specific problematic hub chip (Fresco Logic)
  services.udev.extraRules = ''
    # Disable autosuspend for the internal Fresco Logic Hub
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1d5c", ATTR{idProduct}=="5801", TEST=="power/control", ATTR{power/control}="on"

    # Disable autosuspend for the Ugreen Dock controller itself
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="3188", ATTR{idProduct}=="5335", TEST=="power/control", ATTR{power/control}="on"
  '';

  boot.loader.grub.configurationLimit = 20;

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
      "kvm"
      "adbusers"
      # "libvirtd"
    ];
    shell = pkgs.zsh;
  };

  networking.firewall.enable = false;
  networking.enableIPv6 = false;
}
