{ config, lib, ... }:

let
  cfg = config.myOptions.dev.git;
  proxy = config.myOptions.proxy;
in {
  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      
      # 使用 extraConfig (对应你代码中的 settings) 来实现完全的声明式配置
      settings = {
        user = {
          name = "j4go";
          email = "yianny@163.com";
        };
        
        push = {
          autoSetupRemote = true;
        };

        # 🚀 动态代理注入逻辑
        # 仅当全局 proxy.enable 为 true 时，以下属性才会被写入 .gitconfig
        http = lib.mkIf proxy.enable {
          proxy = "http://${proxy.address}";
        };
        
        https = lib.mkIf proxy.enable {
          proxy = "http://${proxy.address}";
        };
      };
    };
  };
}
