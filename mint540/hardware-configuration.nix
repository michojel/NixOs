# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ /mnt/nixos/common/hardware-configuration.nix ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];

  fileSystems."/" =
    { device = "enctank/mint540/root";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "enctank/mint540/home";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "enctank/mint540/tmp";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "enctank/mint540/nix";
      fsType = "zfs";
    };

  fileSystems."/mnt/nixos" =
    { device = "enctank/nixos";
      fsType = "zfs";
    };

  fileSystems."/home/miminar/Documents" =
    { device = "encbig/miminar/documents";
      fsType = "zfs";
    };
    
  fileSystems."/home/miminar/Pictures" =
    { device = "encbig/miminar/pictures";
      fsType = "zfs";
    };
    
  fileSystems."/home/miminar/Audio" =
    { device = "encbig/miminar/audio";
      fsType = "zfs";
    };
    
  fileSystems."/home/miminar/Video" =
    { device = "encbig/miminar/video";
      fsType = "zfs";
    };
    
  fileSystems."/home/miminar/Downloads" =
    { device = "encbig/miminar/downloads";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-partuuid/287e82fa-5cea-443e-b4bb-000ccb6103de";
      fsType = "ext4";
      options = ["noatime"];
    };

  fileSystems."/boot/EFI" =
    { device = "/dev/disk/by-uuid/44F9-11FA";
      fsType = "vfat";
    };

  fileSystems."/var/lib/docker" =
    { device = "/dev/disk/by-uuid/907b9703-22a4-4b5d-9ab0-e6269cc9e290";
      fsType = "xfs";
      options = [ "noatime" "discard" "nofail" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/18759983-9a0b-4d65-b68a-bcb6aa90a3dc"; }
    ];

  nix.maxJobs = lib.mkDefault 8;

  hardware = {
    # Manage Optimus hybrid Nvidia video cards
    # TODO: make it work
    #bumblebee.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
    #steam-hardware.enable = true;
    pulseaudio.enable       = true;
    trackpoint.enable       = true;
  };
}

# ex: set et ts=2 sw=2 :
