{ ... }:
{
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;
}
