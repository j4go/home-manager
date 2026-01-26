{ pkgs, ... }: {
  imports = [
    #./modules/zsh.nix
    ./modules/bash.nix
    ./modules/starship.nix
    ./modules/git.nix
    ./modules/packages.nix
  ];

  # 用户基础信息
  home.username = "w";
  home.homeDirectory = "/home/w";
  
  # 状态版本号 (不要随意修改)
  home.stateVersion = "24.05";

  # 启用 Home Manager 自身
  programs.home-manager.enable = true;
}
