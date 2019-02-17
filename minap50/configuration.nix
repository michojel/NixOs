# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  encryptedPoolName = "encbig";

  zfs-load-key = pkgs.writeTextFile {
    name = "zfs-load-key.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      readonly ATTEMPTS=3
      POOLNAME="''${1:-${encryptedPoolName}}"

      if ! ${pkgs.zfsUnstable}/bin/zpool list -H -o load_guid "''${POOLNAME}" >/dev/null 2>&1; then
        ${pkgs.zfsUnstable}/bin/zpool import -d "/dev/disk/by-id" -N "''${POOLNAME}" || :
      fi
      ${pkgs.zfsUnstable}/bin/zfs list -H -o keystatus "''${POOLNAME}" |& grep -q "^available" && exit 0
      for ((i=0; i < ''${ATTEMPTS}; i++)); do
        ${pkgs.systemd}/bin/systemd-ask-password "Password for ''${POOLNAME} encrypted storage: " | \
          ${pkgs.zfsUnstable}/bin/zfs load-key "''${POOLNAME}" && exit 0
      done
      exit 1
    '';
  };

in {
  imports =
    [ ./hardware-configuration.nix
      ./bind-mounts.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/pkgs.nix
      ./pkgs.nix
      ./samba.nix
      /mnt/nixos/common/screensaver.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
    maxJobs = 4;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion       = "18.09";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-18.09";

  time.timeZone = "Europe/Prague";

  networking = {
    hostName = "minap50"; # Define your hostname.
    hostId   = "f1e5c49e";

    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      dynamicHosts.enable = true;
      extraConfig = ''
        [logging]
        level = DEBUG
        domains = ALL
      '';
    };

    # Open ports in the firewall.
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22    # ssh
        #5201  # iperf
        # 24800 # synergy server
      ];
      allowedUDPPorts = [
        #5201  # iperf
        #24800 # synergy server
      ];
      extraCommands = ''
        # samba
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 139 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i lo       --dport 445 -j ACCEPT
        iptables -A INPUT -m state --state NEW -m tcp -p tcp -i vboxnet0 --dport 445 -j ACCEPT
      '';
      allowPing = true;
    };
  };

  hardware = {
    pulseaudio.enable       = true;
    pulseaudio.support32Bit = true;
    trackpoint.enable       = true;
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
      timeout                  = 2;
    };
    zfs = {
      enableUnstable               = true;
      requestEncryptionCredentials = true;
    };
    supportedFilesystems = ["zfs"];
  };

  programs = {
    adb.enable  = true;
    chromium    = {
      enable    = true;
      extraOpts = {
        "AuthServerWhitelist"            = "*.redhat.com";
        "AuthNegotiateDelegateWhitelist" = "*.redhat.com";
      };
    };
    dconf.enable          = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  services = {
    hoogle.enable   = true;
    openssh.enable  = true;
    printing = {
      enable = true;
      drivers = [pkgs.gutenprint pkgs.hplip pkgs.splix];
    };
    psd = {
      enable = true;
      browsers = [ "chromium" "firefox" ];
      users = ["miminar"];
    };
    nginx = {
      enable = true;
      #root = "/var/www";
      #listen = [ { addr = "127.0.0.1"; port = 80; } { addr = "192.168.122.1"; port = 80; } ];
    };

    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };

    udev = {
      packages = [ unstable.steamPackages.steam ];
      extraRules =
      ''
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="54:e1:ad:8f:73:1f", NAME="net0"
        SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="d2:60:69:25:9b:47", NAME="wlan0"
        ACTION=="add",   KERNEL=="i2c-[0-9]", GROUP="i2c"
      '';
    };

    smartd = {
      enable = true;
      notifications = {
        x11.enable = true;
        test = true;
      };
    };

    autorandr.enable = true;

    xserver = {
      enable = true;

      layout = "us,cz,ru";
      xkbVariant = ",qwerty,";
      xkbOptions = "grp:shift_caps_toggle,terminate:ctrl_alt_bksp,grp:switch,grp_led:scroll";

      libinput = {
        enable = true;
        clickMethod = "none";
        naturalScrolling = true;
        tapping = false;
      };

      config =
        ''
          Section           "InputClass"
            Identifier      "Logitech Trackball"
            Driver          "evdev"
            MatchProduct    "Trackball"
            MatchIsPointer  "on"
            MatchDevicePath "/dev/input/event*"
            Option          "ButtonMapping"      "1 8 3 4 5 6 7 2 9"
            Option          "EmulateWheel"       "True"
            Option          "EmulateWheelButton" "9"
            Option          "XAxisMapping"       "6 7"
          EndSection
        '';

      # create a symlink target /etc/X11/xorg.conf
      exportConfiguration = true;

      desktopManager.lxqt.enable = true;
      desktopManager.default = "lxqt";

      displayManager.sddm.enable = true;
      videoDrivers = [ "intel" "nvidia" ];
    };
  };

  # TODO: automate the certs.nix file creation
  security.pki.certificates = import /mnt/nixos/secrets/certs/certs.nix;
#    [
#    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
#    certs/SAP-Global-Root-CA.crt
#    certs/2015-RH-IT-Root-CA.pem
#    certs/Eng-CA.crt
#    certs/newca.crt
#    certs/oracle_ebs.crt
#    certs/pki-ca-chain.crt
  #];

  krb5 = {
    enable = true;

    domain_realm = {
      ".redhat.com" = "REDHAT.COM";
      "redhat.com"  = "REDHAT.COM";
    };

    libdefaults = {
      default_ccache_name = "KEYRING:persistent:%{uid}";
      default_realm       = "REDHAT.COM";
      dns_lookup_kdc      = false;
      dns_lookup_realm    = "false";
      forwardable         = "true";
      rdns                = "false";
      renew_lifetime      = "7d";
      ticket_lifetime     = "24h";
    };

    realms = {
      "REDHAT.COM" = {
        "master_kdc"   = "kerberos.corp.redhat.com";
        "admin_server" = "kerberos.corp.redhat.com";
        # TODO: allow for multiple kdc lines
        "kdc"          = "kerberos01.core.prod.int.rdu2.redhat.com.:88";
        #"kdc" = "kerberos02.core.prod.int.rdu2.redhat.com";
        #"kdc" = "kerberos02.core.prod.int.phx2.redhat.com";
        #kdc = kerberos01.core.prod.int.phx2.redhat.com.:88
        #kdc = kerberos01.core.prod.int.ams2.redhat.com.:88
        #kdc = kerberos01.core.prod.int.sin2.redhat.com.:88
      };
      "FEDORAPROJECT.ORG" = {
        ".fedoraproject.org" = "FEDORAPROJECT.ORG";
        "fedoraproject.org" = "FEDORAPROJECT.ORG";
      };
    };  
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    extraUsers = {
      miminar = {
        isNormalUser = true;
        uid          = 1000;
        extraGroups  = [
          "networkmanager" "wheel" "audio" "fuse"
          "docker" "utmp" "i2c" "cdrom" "libvirtd"
          "vboxusers"
          ];
      };
    };
    extraGroups = {
      i2c = { gid = 546; };
    };
  };

  virtualisation.docker.enable          = true;
  virtualisation.docker.enableOnBoot    = true;
  virtualisation.virtualbox.host.enable = true;

  systemd = {
    generator-packages = [ 
      pkgs.systemd-cryptsetup-generator
    ];
    services = {
      zfs-import-encdedup.unitConfig.RequiresMountsFor = "/mnt/nixos/secrets/luks/encdedup";
      zfs-import-encuncomp.unitConfig.RequiresMountsFor = "/mnt/nixos/secrets/luks/encuncomp";
      "zfs-key-${encryptedPoolName}" = {
        wantedBy = ["zfs.target"];
        after = config.systemd.services."zfs-import-${encryptedPoolName}".after;
        before = ["zfs-import-${encryptedPoolName}.service" "zfs-mount.service" "systemd-user-sessions.service"];
        description = "Load storage encryption keys";
        unitConfig = {
          DefaultDependencies = "no";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = "yes";
          ExecStart = "${zfs-load-key} ${encryptedPoolName}";
        };
      };
    };
  };
}

# ex: et ts=2 sw=2 :
