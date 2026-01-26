{ pkgs, ... }: {
  programs.ssh = {
    enable = true;
    
    # ✅ 针对 GitHub 的特殊配置
    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # 核心魔法：使用 netcat (nc) 通过代理转发 SSH 流量
        # -X 5 代表 SOCKS5 协议
        # -x 代理地址
        proxyCommand = "nc -X 5 -x 10.255.126.1:10808 %h %p";
      };
    };
  };
}
