{ config, ... }:

{
  fileSystems."/etc/nixos" =
    { device = "/mnt/nixos/mounter";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
      ]; 
    };

  fileSystems."/home/miminar/wsp/nixos" =
    { device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
      ];
    };

}

# vim: set et ts=2 sw=2 ft=nix :
