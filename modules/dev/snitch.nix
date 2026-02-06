#                _ __       __
#    _________  (_) /______/ /_
#   / ___/ __ \/ / __/ ___/ __ \
#  (__  ) / / / / /_/ /__/ / / /
# /____/_/ /_/_/\__/\___/_/ /_/
#
{
  config,
  pkgs,
  snitch,
  ...
}: {
  programs.snitch = {
    enable = true;
    settings = {
      defaults = {
        theme = "catppuccin-mocha";
        interval = "2s";
        resolve = true;
      };
    };
  };
}
