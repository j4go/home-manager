{lib, ...}:
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
      starship.enable = mkEnableOption "Starship 提示符";
    };
  };
}
