{ config, lib, pkgs, ... }:

let
  proxy = config.myOptions.proxy;
  # 锁定 OpenBSD 版本的 nc 路径，防止调用到系统的 Ncat
  nc = "${pkgs.netcat-openbsd}/bin/nc";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = true;

    matchBlocks = {
      "*" = { addKeysToAgent = "yes"; };

      "github.com" = {
        # 🚀 绝招 1: 使用 443 端口 (GitHub 的 SSH 备用端口)
        # 很多代理服务器会拦截 22 端口，但不会拦截 443
        hostname = "ssh.github.com";
        port = 443;
        user = "git";

        # 🚀 绝招 2: 锁定路径并尝试 HTTP CONNECT 协议
        # 如果你的代理地址 10808 实际上是 HTTP 代理，用 -X 5 必断
        # 请根据测试结果选择：
        # - SOCKS5 代理用: -X 5
        # - HTTP 代理用:   -X connect
        proxyCommand = lib.mkIf proxy.enable 
          "${nc} -X connect -x ${proxy.address} %h %p";
      };
    };
  };
}
