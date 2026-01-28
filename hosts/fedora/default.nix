{ ... }: {
  imports = [
    ../../modules/common-import.nix
  ];

  # 🚀 为这台机器量身定做开关
  myOptions = {
    proxy = {
      enable = true;
      address = "192.168.3.248:10808";
    };
    shell.zsh.enable = false;
    shell.bash.enable = true;
    shell.starship.enable = true;
  };

  # 机器特定的基本信息
  home.username = "w";
  home.homeDirectory = "/home/w";
}
