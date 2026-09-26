{ ... }:
{
  programs.git = {
    enable = true;
    # The system provides Git for both users and root maintenance.
    package = null;
    settings.user = {
      name = "suxiaoshao";
      email = "48886207+suxiaoshao@users.noreply.github.com";
    };
  };
}
