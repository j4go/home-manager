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
    # 将通用函数定义在这里，所有项目都能直接调用
    stdlib = ''

         layout_python_flex() {
           local env_name=$1
           # 1. 设置默认值为 3.13.12
           local requested_version=''${2:-3.13.12}
           local max_supported="3.14.3"

           # 2. 版本号比较逻辑 (简单字符串/数字比较)
           # 使用 sort -V 进行语义化版本比较
           local final_version=$(echo -e "$requested_version\n$max_supported" | sort -V | head -n1)

           if [ "$requested_version" != "$final_version" ]; then
             echo "⚠️  Requested $requested_version exceeds max supported $max_supported."
             echo "🛡️  Falling back to $max_supported"
             final_version=$max_supported
           fi

           echo "🚀 Python Version: $final_version"

           # 3. 执行 Micromamba 逻辑
           eval "$(micromamba shell hook -s bash)"
           if [ ! -d "$MAMBA_ROOT_PREFIX/envs/$env_name" ]; then
             micromamba create -n "$env_name" python=$final_version -c conda-forge -y
           fi

           micromamba activate "$env_name"

           # 4. 绑定 uv
           export UV_PYTHON="$(which python)"
           if [ -f "pyproject.toml" ]; then
             uv sync --quiet
           fi
      }
    '';
  };
}
