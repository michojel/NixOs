# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #/mnt/nixos/common/essentials.nix
      #/mnt/nixos/common/user.nix
      /mnt/nixos/common/shell.nix
      /mnt/nixos/common/nginx-wordpress.nix
      #/mnt/nixos/common/pkgs.nix
      ./bind-mounts.nix
    ];

  # Use the GRUB 2 boot loader.
  boot = {
    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.efiSupport = false;
      #  grub.efiInstallAsRemovable = true;
      #  efi.efiSysMountPoint = "/boot/efi";
      # Define on which hard drive you want to install Grub.
      grub.device = "/dev/vda"; # or "nodev" for efi only
      grub.copyKernels = true;
    };
    supportedFilesystems = [ "btrfs" "xfs" ];
    cleanTmpDir = true;
    loader.timeout = 31;
  };

  nix = {
    autoOptimiseStore = true;
    gc = {
      automatic = true;
      dates = "03:15";
      # Options given to nix-collect-garbage when the garbage collector is run automatically. 
      options = "--delete-older-than 21d";
    };
  };

  systemd = {
    tmpfiles.rules = [ "d /tmp 1777 root root 11d" ];
    services.nixos-upgrade = {
      preStart = ''
        set -euo pipefail
        ${pkgs.sudo}/bin/sudo -u miminar "${pkgs.bash}/bin/bash" \
          -c 'cd /home/miminar/wsp/nixos && git pull https://github.com/michojel/NixOS master'
        ${pkgs.nix}/bin/nix-channel --update nixos-unstable
      '';
      postStart = ''
        ${pkgs.sudo}/bin/sudo -u miminar "${pkgs.bash}/bin/bash" \
          -c 'cd $HOME && nix-env --upgrade "*"
            nix-env -iA nixos.chromium-wrappers nixos.w3'
        # remove when https://github.com/NixOS/nixpkgs/pull/86489 is available
      '';
      requires = pkgs.lib.mkAfter [ "network-online.target" ];
      after = pkgs.lib.mkAfter [ "network-online.target" ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    useDHCP = false;
    hostName = "michowps";
    hostId = "f08e11d9";
    domain = "michojel.cz";
    interfaces.ens3 = {
      useDHCP = false;
      ipv4 = {
        addresses = [{ address = "31.31.73.95"; prefixLength = 24; }];
      };
      ipv6 = {
        addresses = [
          { address = "2a02:2b88:2:1::6c17:1"; prefixLength = 64; }
          { address = "2a02:2b88:6:6c17::1"; prefixLength = 48; }
        ];
      };
    };
    nameservers = [
      "46.28.108.2"
      "31.31.72.3"
      "2a02:2b88:2:1::2552:1"
      "2a02:2b88:2:1::af4:1"
    ];
    defaultGateway = { address = "31.31.73.1"; interface = "ens3"; };
    #defaultGateway6 = { address = "2a02:2b88:2:1::1"; interface = "ens3"; };
    defaultGateway6 = { address = "2a02:2b88:6::1"; interface = "ens3"; };

    # Open ports in the firewall.
    firewall = {
      allowedTCPPorts = [ 22 80 443 ];
      # networking.firewall.allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      enable = true;
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };



  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.michojel = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = lib.mkAfter [
      "cdrom"
      "docker"
      "fuse"
      "i2c"
      "plugdev"
      "utmp"
      "wheel"
    ];
  };
  users.extraGroups.i2c = {
    gid = 546;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixpkgs-fmt
    nix-linter
    nix-review
    sqlite
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services = {
    openssh.enable = true;
    btrfs.autoScrub.enable = true;
    irqbalance.enable = true;

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."gitlab.michojel.cz" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
      virtualHosts."anki.michojel.cz" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:27701";
      };
    };

    gitlab = {
      enable = true;
      databasePasswordFile = "/var/keys/gitlab/db_password";
      initialRootPasswordFile = "/var/keys/gitlab/root_password";
      initialRootEmail = "mm@michojel.cz";
      https = true;
      host = "gitlab.michojel.cz";
      port = 443;
      user = "git";
      group = "git";
      databaseUsername = "git";
      smtp = {
        enable = true;
        address = "localhost";
        port = 25;
      };
      secrets = {
        dbFile = "/var/keys/gitlab/db";
        secretFile = "/var/keys/gitlab/secret";
        otpFile = "/var/keys/gitlab/otp";
        jwsFile = "/var/keys/gitlab/jws";
      };
      extraConfig = {
        gitlab = {
          email_from = "gitlab-no-reply@michojel.cz";
          email_display_name = "Michojel's GitLab";
          email_reply_to = "gitlab-no-reply@michojel.cz";
          default_projects_features = { builds = false; };
        };
      };
    };

    ankisyncd = {
      enable = true;
    };

    nginxWordpress =
      let
        responsiveTheme = pkgs.stdenv.mkDerivation {
          name = "responsive-theme";
          # Download the theme from the wordpress site
          src = pkgs.fetchurl {
            url = http://wordpress.org/themes/download/responsive.4.5.2.zip;
            #sha256 = "06i26xlc5kdnx903b1gfvnysx49fb4kh4pixn89qii3a30fgd8r8";
            #sha256 = "1g1mjvjbx7a0w8g69xbahi09y2z8wfk1pzy1wrdrdnjlynyfgzq8";
            sha256 = "1y9npjq3279rcg61cbcwfz30dxdgl0gcj8bihlwkb07xhw5ar196";
          };
          # We need unzip to build this package
          buildInputs = [ pkgs.unzip ];
          # Installing simply means copying all files to the output directory
          installPhase = "mkdir -p $out; cp -R * $out/";
        };

        # Wordpress plugin 'akismet' installation example
        akismetPlugin = pkgs.stdenv.mkDerivation {
          name = "akismet-plugin";
          # Download the theme from the wordpress site
          src = pkgs.fetchurl {
            url = https://downloads.wordpress.org/plugin/akismet.4.1.8.zip;
            #sha256 = "1i4k7qyzna08822ncaz5l00wwxkwcdg4j9h3z2g0ay23q640pclg";
            #sha256 = "1wjq2125syrhxhb0zbak8rv7sy7l8m60c13rfjyjbyjwiasalgzf";
            sha256 = "1zbv0vg7l9sc3y5ppyiaw5wmk8kmbc2wi5gcgnd9w9bs0da349dd";
          };
          # We need unzip to build this package
          buildInputs = [ pkgs.unzip ];
          # Installing simply means copying all files to the output directory
          installPhase = "mkdir -p $out; cp -R * $out/";
        };

      in
      {
        "laskavoucestou.cz" = {
          database = {
            host = "127.0.0.1";
            name = "wordpress";
            passwordFile = "/var/keys/wordpress/laskavoucestou.cz/db_password";
            createLocally = true;
          };
          themes = [ responsiveTheme ];
          plugins = [ akismetPlugin ];
        };
      };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      email = "mm@michojel.cz";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}
