{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "j4go";
        email = "yianny@163.com";
      };
      # HTTP/HTTPS 代理配置
      http = {
        proxy = "http://10.255.126.1:10808";
      };
      https = {
        proxy = "http://10.255.126.1:10808";
      };
    };
  };
}
