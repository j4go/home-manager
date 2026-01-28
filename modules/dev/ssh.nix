{ config, lib, pkgs, ... }:

let
  proxy = config.myOptions.proxy;
  # 自动下载并锁定绝对路径
  nc = "${pkgs.netcat-openbsd}/bin/nc";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = true;

    matchBlocks = {
      "github.com" = {
        # 强制使用 443 端口，绕过可能的 22 端口封锁
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        
        # 动态注入 ProxyCommand
        proxyCommand = lib.mkIf proxy.enable 
          # 建议先试 -X connect (HTTP 协议)，如果不行再试 -X 5 (SOCKS 协议)
          "${nc} -X connect -x ${proxy.address} %h %p";
      };
    };
  };
}
