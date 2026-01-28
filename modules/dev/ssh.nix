{ config, lib, pkgs, ... }:

let
  proxy = config.myOptions.proxy;
in {
  programs.ssh = {
    enable = true;
    
    # ✅ 建议改为 true，以包含系统基础配置
    enableDefaultConfig = true; 

    matchBlocks = {
      "*" = { 
        addKeysToAgent = "yes"; 
      };
      
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # 🚀 增加判断：确保 proxy.address 不为空且开启
        proxyCommand = lib.mkIf (proxy.enable && proxy.address != "") 
          # 如果你的代理是 Clash/V2Ray，通常 7890 端口同时支持 HTTP 和 SOCKS
          # 这里推荐使用 nc -X 5 (SOCKS5)
          "${pkgs.netcat-openbsd}/bin/nc -X 5 -x ${proxy.address} %h %p";
      };
    };
  };
}
