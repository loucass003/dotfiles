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
    # ../../nixos/gnome
    ../../nixos/kde
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
    "thunderbolt"
    "nvidia"
  ];
  boot.kernelModules = [ 
    "kvm-amd" 
    "thunderbolt"
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
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
    videoDrivers = [ "amdgpu" "nvidia" ];
    # desktopManager.gnome.enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  hardware.graphics = {
    ## radv: an open-source Vulkan driver from freedesktop
    enable32Bit = true;
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      nvidia-vaapi-driver
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

  };

  # systemd.services.nvidia-suspend.enable = true;
  # systemd.services.nvidia-resume.enable = true;
  # systemd.services.nvidia-hibernate.enable = true;

  hardware.nvidia.prime = {
    allowExternalGpu = true;
  };
	    
	services.thermald.enable = true;

  boot.kernelParams = [
    "usbcore.autosuspend=-1"
    "usbcore.quirks=3188:5335:k"
    # "pcie_aspm=off"
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

    # UGREEN Dock - Improved power management matching (replacing the Bus 5 rule)
    # Matches the Fresco Logic hub inside your dock specifically
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="1d5c", ATTRS{idProduct}=="5801", ATTR{bConfigurationValue}="1"


    # When NVIDIA eGPU is removed - only trigger on Thunderbolt PCI devices
    ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", SUBSYSTEMS=="thunderbolt", RUN+="${pkgs.systemd}/bin/systemctl start nvidia-egpu-remove.service"

    # When NVIDIA eGPU is added - only trigger on Thunderbolt PCI devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", SUBSYSTEMS=="thunderbolt", RUN+="${pkgs.systemd}/bin/systemctl start nvidia-egpu-add.service"
  '';

  systemd.services.nvidia-egpu-remove = {
    description = "Handle NVIDIA eGPU removal";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "nvidia-egpu-remove" ''
        # Kill any processes using the NVIDIA GPU (optional but helps)
        ${pkgs.lsof}/bin/lsof /dev/nvidia* 2>/dev/null | ${pkgs.gawk}/bin/awk 'NR>1 {print $2}' | ${pkgs.findutils}/bin/xargs -r kill -9 2>/dev/null || true
        
        # Unbind all NVIDIA devices
        for dev in /sys/bus/pci/drivers/nvidia/*; do
          if [ -e "$dev/remove" ]; then
            echo 1 > "$dev/remove" 2>/dev/null || true
          fi
        done
        
        # Wait a bit
        sleep 1
        
        # Try to unload modules (may fail, that's ok)
        ${pkgs.kmod}/bin/modprobe -r nvidia_drm 2>/dev/null || true
        ${pkgs.kmod}/bin/modprobe -r nvidia_modeset 2>/dev/null || true
        ${pkgs.kmod}/bin/modprobe -r nvidia_uvm 2>/dev/null || true
        ${pkgs.kmod}/bin/modprobe -r nvidia 2>/dev/null || true
      '';
    };
  };

  systemd.services.nvidia-egpu-add = {
    description = "Handle NVIDIA eGPU connection";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "nvidia-egpu-add" ''
        # Wait for device to stabilize
        sleep 2
        
        # Rescan PCI bus to ensure device is detected
        echo 1 > /sys/bus/pci/rescan 2>/dev/null || true
        
        # Load NVIDIA modules
        ${pkgs.kmod}/bin/modprobe nvidia
        ${pkgs.kmod}/bin/modprobe nvidia_modeset
        ${pkgs.kmod}/bin/modprobe nvidia_uvm
        ${pkgs.kmod}/bin/modprobe nvidia_drm
        
        # Create device nodes
        ${pkgs.kmod}/bin/modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia 2>/dev/null || true
        ${pkgs.kmod}/bin/modprobe nvidia nvidia_modeset nvidia_uvm nvidia_drm
      '';
    };
  };

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
