#        ___
#   ____/ (_)_______  ____ _   __
#  / __  / / ___/ _ \/ __ \ | / /
# / /_/ / / /  /  __/ / / / |/ /
# \__,_/_/_/   \___/_/ /_/|___/
#
{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # 自动挂载到 Bash

    # 🚀 核心优化：使用 nix-direnv 实现缓存
    # 这能极大加快 shell 加载速度，避免每次 cd 都重新计算 Nix 表达式
    nix-direnv.enable = true;
  };
}
