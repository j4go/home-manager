{ pkgs, inputs, system, ... }:

let 
  # 核心：从 inputs 中获取 unstable 的包集
  unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
in {
  home.packages = 
    # 1. 主体包：使用稳定的 pkgs
    (with pkgs; [
      ripgrep       # 极速搜索
      fd            # 极速查找
      jq            # JSON 处理
      xclip         # 剪贴板 (X11)
      wl-clipboard  # 剪贴板 (Wayland)
      trash-cli     # 安全删除
      hyperfine     # 基准测试工具
      
      # 压缩解压工具套装
      zip
      unzip
      _7zz          # 现代 7zip 
    ]) 
    
    # 2. 增量包：使用 unstablePkgs
    ++ [
      unstablePkgs.fastfetch
    ];
}
