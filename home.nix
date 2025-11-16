{ config, pkgs, ... }:

{
  # TODO please change the username & home directory to your own
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    # shell
    starship
    # nil dev
    nil
    nixfmt-rfc-style
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "suxiaoshao";
    userEmail = "48886207+suxiaoshao@users.noreply.github.com";
    # safe.directory = [ "/etc/nixos" ];
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      username.show_always = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:/home/nixos/.cargo/bin"
      eval "$(starship init bash)"
    '';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.05";
}
