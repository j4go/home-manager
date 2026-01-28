{ config, lib, pkgs, ... }:

let
  proxy = config.myOptions.proxy;
  nc = "${pkgs.netcat-openbsd}/bin/nc";
in {
  programs.ssh = {
    enable = true;
    
    # ✅ 1. 听从警告：关闭隐式默认配置，改为完全声明式
    enableDefaultConfig = false; 

    matchBlocks = {
      # ✅ 2. 将全局默认行为显式写在 "*" 匹配块中
      "*" = { 
        # 自动将密钥添加到 SSH Agent
        addKeysToAgent = "yes"; 
        
        # 保持连接活跃
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        
        # 允许通过控制套件复用连接 (提升多次连接同一主机的速度)
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";
        controlPersist = "10m";
      };
      
      # ✅ 3. 特定主机的代理逻辑
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
        proxyCommand = lib.mkIf proxy.enable 
          # 建议使用 -X connect (根据你之前的测试)
          "${nc} -X connect -x ${proxy.address} %h %p";
      };
    };
  };
}
