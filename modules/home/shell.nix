{ pkgs, ... }:

{
  home.packages = with pkgs; [
    starship
  ];

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      username.show_always = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin"
      eval "$(starship init bash)"
    '';
  };
}
