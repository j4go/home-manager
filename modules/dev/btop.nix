{ config, pkgs, lib, ... }:
{
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "dracula";
      theme_background = false; # 透明背景
      update_ms = 500;          # 刷新频率
    };
  };
}
