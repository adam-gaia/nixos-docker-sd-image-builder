{lib, ...}: let
  ssid = lib.strings.removeSuffix "\n" (builtins.readFile ./wifi/ssid);
in {
  imports = [
    ## Uncomment at most one of the following to select the target system:
    # ./generic-aarch64 # (note: this is the same as 'rpi3' and 'rpi4')
    ./rpi4
    #./rpi3
  ];

  # The installer starts with a "nixos" user to allow installation, so add the SSH key to
  # that user. Note that the key is, at the time of writing, put in `/etc/ssh/authorized_keys.d`
  users.extraUsers.nixos.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCzbPCWRK+1Zd2EMzjEOn7cjMJ+QksEtGKGvJ/3zwP2UkJk417IP3THACSzDUBSZ4i4XpFcXxLeUwQMHNFfq+6ZRdeahG5Z7YfT0LTLaS4uzYmrEoz7ZHwMzjSbIvYhntfR6OAprq0iG4rhjSy6laiFF+6tEkLtJ3GmPpjT3z2P5hFmm49pdBYLNmZPpfofUykRbF+5NQK6enf35l4l4+ctKEhrW7Q1OAgvkXFa6qBBAHWNlQDeiUSQG1wRKbslg97WZk/ElJP7eMf8drSbCJ6Wj2fciGZUw5kFX+3GRBMK8JjcfidFjpEsMWRLG5QAzeUujrNkKqs3LP2vr+9SLReX2GarUK55WXkkB3ZPnggSwGwDGXY/XHKmHtJN9EvZeCnT7l/R+yneu6FlJ7Rio56L6PXwx6sbes5EGlkYzIExn1SgPTB15XEZgt9qYQf9+LESUm0DxbYNaJOPB0hb42X/ZNtaYjdIGRiouktNwU3yl3H2VpCRtUdtVlDya9DRYlyd+Cp0lYdcFix/2bVDxsdkk/gTymB8XkZNSEHGfi0lYs6DUXThJHVtm/bUcM34whebnKUzBx786UnwX72DcFEV9t5HRCJLoZCtN188DFE4S9Yze3AeHhnvpj0H/+wFIYwsvIXoI7aMOvj2D3IxDHuxTMIdCwCSJ9+ldhmr/CDOQ== agaia@orion Generated Mon Sep 19 12:28:08 PM MDT 2022"
  ];

  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  # Note said to inrease boot size for trial and error building of stuff
  sdImage.firmwareSize = 1024;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 ["multi-user.target"];

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;

  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
  networking.wireless = {
    enable = true;
    interfaces = ["wlan0"];
    networks = {
      "${ssid}" = {
        psk = lib.strings.removeSuffix "\n" (builtins.readFile ./wifi/password);
      };
    };
  };

  # Wireless networking (2). Enables `wpa_supplicant` on boot.
  #systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 10 [ "default.target" ];

  # NTP time sync.
  #services.timesyncd.enable = true;
}
