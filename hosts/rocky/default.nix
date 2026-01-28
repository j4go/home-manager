{ ... }: {
  # 导入所有可能的模块（但生效与否由下方的开关决定）
  imports = [
    ../../modules/shell/zsh.nix
    ../../modules/shell/bash.nix
    ../../modules/shell/starship.nix
    ../../modules/editors/neovim.nix
    ../../modules/dev/git.nix
    ../../modules/dev/ssh.nix
    ../../modules/dev/direnv.nix
    ../../modules/core/packages.nix
  ];

  # 🚀 为这台机器量身定做开关
  myOptions = {
    proxy = {
      enable = true;
      address = "10.255.126.1:10808";
    };
    shell.zsh.enable = false;
    shell.bash.enable = true;
    shell.starship.enable = true;
    editors.neovim.enable = true;
    dev.git.enable = true;
    dev.ssh.enable = true;
    dev.direnv.enable = true;
    dev.packages.enable = true;
  };

  # 机器特定的基本信息
  home.username = "w";
  home.homeDirectory = "/home/w";
}
