{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        # 你可以在这里添加其他通用配置，如:
        # identityFile = "~/.ssh/id_ed25519";
      };

      # GitHub 专用配置
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
