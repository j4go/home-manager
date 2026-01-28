{ config, lib, pkgs, ... }:

let
  # 依然需要读取全局的代理配置，以便动态生成 ProxyCommand
  proxy = config.myOptions.proxy;
in {
  programs.ssh = {
    enable = true;
    
    enableDefaultConfig = false; 

    matchBlocks = {
      "*" = { 
        addKeysToAgent = "yes"; 
      };
      
      "github.com" = {
        hostname = "github.com";
        user = "git";
        # 这里的 lib.mkIf 依然有效：只有当全局 proxy 开启时，才会写入这行 ProxyCommand
        proxyCommand = lib.mkIf proxy.enable 
          "${pkgs.netcat-openbsd}/bin/nc -X 5 -x ${proxy.address} %h %p";
      };
    };
  };
}
