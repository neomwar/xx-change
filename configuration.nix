# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

# NOTE(akavel): notes to self: # copied his (akavel) configuration notes to my configuration + some of mine
#   nix-env -qaP --description # list all available pkgs
#   nix-env -qaP '.*chrome.*'  # search for a package witch you don't know the full name and attribute path
#   nix-env --dry-run -i git   # dependencies of a pkg
#   nixos-rebuild dry-build    # do not build
#   nixos-rebuild build        # build only (generates link named 'result')
#   nixos-rebuild dry-activate # build & simulate switch (may be incomplete)
#   nixos-rebuild test         # build & switch OS, but don't set boot default
#   nixos-rebuild switch       # build & switch OS & set boot default
#   https://nixos.org/nixpkgs/manual  # how to develop and contribute to NixOS packages
#   nix-store -q --tree /nix/var/nix/profiles/system  # list installed pkgs and their dependencies; https://nixos.org/wiki/Cheatsheet
#   nix-store -q --references /var/run/current-system/sw | cut -d- -f2- | sort | less   # list installed NixOS packages;  https://nixos.org/wiki/Install/remove_software#How_to_list_installed_software
#   nix-channel --add https://nixos.org/channels/nixos-unstable nixos   # bleeding edge; enables command-not-found, reportedly? https://github.com/NixOS/nixpkgs/issues/12044
#   nix-env -p /nix/var/nix/profiles/system --list-generations   # list nixos generations


{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];


  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.timeout = 2;

  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  # Boot wireless module for card Broadcom Corporation BCM43142 802.11b/g/n (rev 01)
  boot.kernelModules = [ "wl" ];
  boot.blacklistedKernelModules = [ "bcma" "nouveau" ];  # it collides with wl module

  # Set default soundcard
  boot.extraModprobeConfig = ''
    options snd_hda_intel enable=0,1
  '';

  # Download broadcom wifi driver
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  networking.hostName = "greygoo"; # Define your hostname.
  networking.firewall.enable = true;
  networking.networkmanager.enable = true;

  # rename interfaces to en0 wl0 (from enp7s0f1 wlp8s0)
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="f0:76:1c:35:37:4f", NAME="philana"
    SUBSYSTEM=="net", ACTION=="add", ATTR{address}=="3c:77:e6:fb:80:bd", NAME="orawl"
  '';

  # Set your time zone.
  time.timeZone = "Europe/Athens";

  # VirtualBox
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "master" ];
  boot.initrd.checkJournalingFS = false;

  # Configuration for installed packages with environment.systemPackages
  nixpkgs.config = {
    allowUnfree = true;
    pulseaudio = true;
  };

  nixpkgs.overlays = [ (self: super: { mySteam = super.steamPackages.steam-chrootenv.override { withPrimus = true; }; } ) ];
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  programs.wireshark.enable = true;
  programs.wireshark.package= pkgs.wireshark-qt;

  # Set environment variables
  environment.variables = {
    EDITOR = "atom";
    SUDO_EDITOR = "nvim";
    SHELL = "${pkgs.fish}/bin/fish";
  };

  # Set shell aliases
  environment.shellAliases = {
    la = "ls --almost-all --human-readable";
    ll = "ls -lh";
    nixg = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    nixc = "cd /etc/nixos";
    nixb = "sudo nixos-rebuild switch";
    gitp = "sudo git push -u origin master";
    atoma = "sudo atom configuration.nix";
  };

  environment.systemPackages = with pkgs; [
    fish # Friendly Interactive SHell
    atom
    kate
    libreoffice
    simplescreenrecorder
    unar
    okular
    gpm
    git
    xboxdrv
    bluez5_28
    tlp
    go-sct

    argus
    aircrack-ng
    bro
    driftnet
    ettercap
    etherape
    gdb
    hashcat
    httping
    hping
    ifenslave
    nagios
    nmap_graphical
    netcat
    msf
    proxychains
    macchanger
    john
    jnettop
    putty
    p0f
    sleuthkit
    snort
    traceroute
    truecrypt
    kismet
    thc-hydra


    pidgin
    hexchat
    mySteam
    glxinfo
    shutter
    smplayer
    mpv
    ntfs3g
    wget
    qbittorrent
    firefox
    chromium
    google-chrome
    gpicview
    gimp
    neovim
    pciutils
    pinta
    blender
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Enable the Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  hardware.opengl.driSupport32Bit = true;
  hardware.bluetooth.enable = true;
  hardware.bumblebee.enable = true;
  hardware.bumblebee.connectDisplay = true;

  # Extra configurations for video
  hardware.cpu.intel.updateMicrocode = true;
  hardware.opengl.extraPackages = with pkgs; [ vaapiIntel ];
  services.xserver.videoDrivers = [ "nvidia intel" ];


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = "/run/current-system/sw/bin/fish";
  users.extraUsers.master = {
    isNormalUser = true;
    uid = 1000;
    description = "Master";
    extraGroups = [ "wheel" "audio" "video" "cdrom" "networkmanager" "lp" "wireshark"];
    initialPassword = "silence";
  };

  users.extraUsers.bd = {
    isNormalUser = true;
    uid = 1001;
    description = "Binary Domain";
    extraGroups = [ "audio" "video" "cdrom" "networkmanager" "lp"];
    initialPassword = "echo";
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Add the NixOS Manual on virtual console 8
  services.nixosManual.showManual = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";


}
