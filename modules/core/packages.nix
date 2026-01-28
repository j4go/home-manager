# modules/core/packages.nix 
{ config, lib, pkgs, inputs, system, ... }:
let 
  cfg = config.myOptions.dev.packages;
  
  # 核心：从 inputs 中获取 unstable 的包集
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
  
in {
  config = lib.mkIf cfg.enable {
    home.packages = 
      # 1. 主体包：使用稳定的 pkgs
      (with pkgs; [
        ripgrep
        fd
        htop
        bat
        jq
        xclip
        wl-clipboard
        trash-cli
      ]) 
      
      # 2. 增量包：使用 unstablePkgs
      ++ [
        unstablePkgs.fastfetch
      ];
  };
}
