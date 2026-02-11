{...}: {
  imports = [
    ../../modules/common-import.nix
  ];

  # 🚀 为这台机器量身定做开关
  myOptions = {
    proxy = {
      enable = true;
      address = "10.255.126.1:10808";
    };
  };

  # 机器特定的基本信息
  home.username = "w";
  home.homeDirectory = "/home/w";
}
