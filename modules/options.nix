{ lib, ... }:
with lib; {
  options.myOptions = {
    proxy = {
      enable = mkEnableOption "是否开启系统代理支持";
      address = mkOption {
        type = types.str;
        default = "127.0.0.1:10808";
        description = "代理服务器地址 (IP:Port)";
      };
    };
    shell = {
      zsh.enable = mkEnableOption "Zsh 模块";
      bash.enable = mkEnableOption "Bash 模块";
      starship.enable = mkEnableOption "Starship 提示符";
    };
    editors = {
      neovim.enable = mkEnableOption "Nixvim 编辑器";
    };
    dev = {
      git.enable = mkEnableOption "Git 版本控制";
      ssh.enable = mkEnableOption "SSH 客户端配置";
      packages.enable = mkEnableOption "常用系统工具包";
    };
  };
}
