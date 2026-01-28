{ config, lib, pkgs, ... }:

let
  # 依然需要读取全局的代理配置，以便动态生成 ProxyCommand
  proxy = config.myOptions.proxy;
in {
  programs.ssh = {
    enable = true;
    
    # 建议设为 true，除非你有非常特殊的 ~/.ssh/config 管理需求
    # 设为 false 会导致 Home Manager 不会覆盖你的 config 文件，但也失去了声明式管理的意义
    enableDefaultConfig = true; 

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
