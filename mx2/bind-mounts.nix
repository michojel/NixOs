{ config, ... }:

{
  fileSystems."/etc/nixos" =
    { device = "/mnt/nixos/mx2";
      noCheck = true;
      options = [
        "bind"
        "x-systemd.device-timeout=2s"
        "x-systemd.requires=mnt-nixos.mount"
        "x-systemd.after=mnt-nixos.mount"
        "x-gvfs-hide"
      ]; 
    };

  fileSystems."/home/miminar/wsp/nixos" =
    { device = "/mnt/nixos";
      noCheck = true;
      fsType = "fuse.bindfs";
      options = [
        "nofail"
        "map=root/miminar:@root/@users"
        "x-gvfs-hide"
      ];
    };

  fileSystems."/home/miminar/.config/nixpkgs" =
    { device  = "/mnt/nixos/user";
      options = [ "nofail" "bind" "x-gvfs-hide" ];
    };
}

# vim: set et ts=2 sw=2 ft=nix :
