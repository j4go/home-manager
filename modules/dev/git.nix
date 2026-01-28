{ config, lib, ... }:

let
  proxy = config.myOptions.proxy;
in {
  programs.git = {
    enable = true;
    
    # ✅ 统一使用 settings (对应 .gitconfig 结构)
    settings = {
      # 1. 用户身份
      user = {
        name = "j4go";
        email = "yianny@163.com";
        # 顺便还能加个签名 key
        # signingkey = "ssh-ed25519 ..."; 
      };
      
      # 2. 核心行为
      init = {
        defaultBranch = "main";
      };

      push = {
        autoSetupRemote = true;
      };
      
      pull = {
        rebase = true; # 推荐：pull 时默认使用 rebase 保持历史干净
      };

      # 3. 动态代理 (逻辑保持不变，这在 settings 里工作得很好)
      http = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
      
      https = lib.mkIf proxy.enable {
        proxy = "http://${proxy.address}";
      };
      
      # 4. 安全目录 (解决多用户/sudo 时的 git 报错)
      safe = {
        directory = "*";
      };
    };
  };
}
