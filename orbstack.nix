{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
    /etc/nixos/incus.nix
    /etc/nixos/orbstack.nix
  ];

  users.users.sushao = {
    uid = 501;
    extraGroups = [
      "wheel"
      "orbstack"
    ];

    # Match OrbStack's default guest user model.
    isSystemUser = true;
    group = "users";
    createHome = true;
    home = "/home/sushao";
    homeMode = "700";
    useDefaultShell = true;
  };

  users.mutableUsers = false;

  time.timeZone = "Asia/Shanghai";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  security.sudo.wheelNeedsPassword = false;
}
