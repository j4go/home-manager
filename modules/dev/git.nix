{ config, lib, ... }:

let
  # 移除了 cfg 变量，保留 proxy 变量用于内部逻辑判断
  proxy = config.myOptions.proxy;
in {
  # 移除了 config = lib.mkIf cfg.enable 包装，改为直接声明
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "j4go";
        email = "yianny@163.com";
      };
      push = {
        autoSetupRemote = true;
      };
      
      # 🚀 动态代理注入逻辑 (保留)
      # 仅当全局 proxy.enable 为 true 时，以下属性才会被写入 .config/git/config
      http = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
      
      https = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
    };
  };
}
