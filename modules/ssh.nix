{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    # ✅ 1. 消除警告：显式启用 SSH Agent 管理 (这是推荐的现代配置)
    addKeysToAgent = "yes";
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # 使用 Nix 提供的 netcat-openbsd 绝对路径
        # 这样无论宿主机是 Rocky 还是 Mint，都能保证 -X 5 参数可用
        proxyCommand = "${pkgs.netcat-openbsd}/bin/nc -X 5 -x 10.255.126.1:10808 %h %p";
      };
    };
  };
}
