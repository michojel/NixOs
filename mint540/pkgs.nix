{ config, pkgs, nodejs, ... }:

with config.nixpkgs;
let
  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  dontRecurseIntoAttrs = x: x;
in
rec {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    libxfs
    ffado
    linuxPackages.usbip

    # work
    awscli
    skopeo
    slack

    # virtualization
    libvirt
    virtmanager

    wine
  ];
}

# ex: set et ts=2 sw=2 :
