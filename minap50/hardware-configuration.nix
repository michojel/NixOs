# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "sr_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [
    "kvm-intel"
    "i2c-dev" # to control monitor brightness
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/52ac0dee-c9cf-4dbf-b82a-1032740d80f4";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E364-7221";
      fsType = "vfat";
      options = ["noatime"];
    };

  fileSystems."/nix" =
    { device = "tank/minap50/nix";
      fsType = "zfs";
      options = ["relatime"];
    };

  fileSystems."/home" =
    { device = "enctank/home";
      fsType = "zfs";
      options = ["relatime"];
    };

  fileSystems."/mnt/nixos" =
    { device = "enctank/nixos";
      fsType = "zfs";
      options = ["relatime"];
    };

  fileSystems."/var/lib/libvirt" =
    { device = "enctank/libvirt";
      fsType = "zfs";
      options = ["relatime"];
    };

  fileSystems."/var/lib/libvirt/images" =
    { device = "enctank/libvirt/images";
      fsType = "zfs";
      options = ["noatime"];
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/3bb39c50-c8f4-4355-bc5a-c836c12de945";
      fsType = "xfs";
      options = [ "noatime" "discard" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/602391ae-1e7d-4ef1-9c40-4a30fb85ccfd"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware ={
    # Manage Optimus hybrid Nvidia video cards
    # TODO: make it work
    #bumblebee.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };
}
