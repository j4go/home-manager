{ pkgs, vars, ... }: {
  programs.git = {
    enable = true;
    userName = "j4go";
    userEmail = "yianny@163.com";
    
    extraConfig = {
      push.autoSetupRemote = true;
      # 🚀 动态注入代理
      http.proxy = "${vars.proxyUrl}";
      https.proxy = "${vars.proxyUrl}";
    };
  };
}
