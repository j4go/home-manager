{ config, lib, pkgs, ... }:
let cfg = config.myOptions.dev.packages;
in {
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep fd htop bat fzf jq xclip wl-clipboard fastfetch
    ];
  };
}
