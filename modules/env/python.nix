{pkgs, ...}: {
  home.packages = with pkgs; [
    micromamba
    uv
  ];

  home.sessionVariables = {
    # 1. 基础根目录
    MAMBA_ROOT_PREFIX = "$HOME/.micromamba";

    # 2. 策略：优先使用受管版本（Mamba 或 uv 下载的）
    # 这保证了如果你在非项目目录下运行 uv，它会去下载 3.14 而不是用系统旧版
    UV_PYTHON_PREFERENCE = "managed";

    # 3. 允许 uv 在找不到符合要求的解释器时自动下载最新的 3.14
    UV_PYTHON_DOWNLOADS = "auto";
  };

  home.activation.createMambaRoot = ''
    mkdir -p $HOME/.micromamba
  '';
}
