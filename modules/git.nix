{ pkgs, ... }: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "j4go";
        email = "yianny@163.com";
      };
      # 可以在这里添加更多 Git 配置，例如 pull.rebase = true
    };
  };
}
