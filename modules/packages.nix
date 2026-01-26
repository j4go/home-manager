{ pkgs, ... }: {
  home.packages = with pkgs; [
    ripgrep
    fd
    htop
    bat
    # 未来新增软件直接加在这里
    # fzf
    # jq
  ];
}
