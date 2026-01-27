{ pkgs, vars, ... }: {
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
      # 动态注入代理
      http = {
        proxy = "${vars.proxyUrl}";
      };
      https = {
        proxy = "${vars.proxyUrl}";
      };
    };
  };
}
