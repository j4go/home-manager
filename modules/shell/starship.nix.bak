#          __                  __    _
#    _____/ /_____ ___________/ /_  (_)___
#   / ___/ __/ __ `/ ___/ ___/ __ \/ / __ \
#  (__  ) /_/ /_/ / /  (__  ) / / / / /_/ /
# /____/\__/\__,_/_/  /____/_/ /_/_/ .___/
#                                 /_/
{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.shell.starship;
  settings = {
    # -------------------------------------------------------------------------
    # 1. 核心格式控制 (Format)
    # -------------------------------------------------------------------------
    # 顺序：用户名 -> 主机名(仅SSH) -> 目录 -> Git -> NixShell -> 换行 -> 提示符
    format = "$username$hostname$directory$git_branch$git_state$git_status$nix_shell$cmd_duration$character";

    # 基础设置
    add_newline = false;
    command_timeout = 1000;

    # -------------------------------------------------------------------------
    # 2. SSH 主机名 (Hostname)
    # -------------------------------------------------------------------------
    hostname = {
      ssh_only = true; # ✅ 关键：只有 SSH 时才显示
      format = "[$ssh_symbol$hostname]($style) ";
      style = "bold #ffaf00"; # 🎃 亮橙色，高辨识度
      ssh_symbol = " ";
      disabled = false;
    };

    # -------------------------------------------------------------------------
    # 3. 用户名 (Username)
    # -------------------------------------------------------------------------
    username = {
      style_user = "white dim";
      show_always = false; # 本地不显示，SSH 时配合 hostname 自动出现
      format = "[$user]($style) @";
      disabled = false;
    };

    # -------------------------------------------------------------------------
    # 4. 其他模块配置
    # -------------------------------------------------------------------------

    # 提示符符号
    character = {
      success_symbol = "[➜](bold green)";
      error_symbol = "[✖](bold red)";
    };

    # 目录
    directory = {
      style = "bold cyan";
      truncation_length = 2;
      format = "[$path]($style) ";
    };

    # Git 分支
    git_branch = {
      symbol = " ";
      style = "bold purple";
      format = "[$symbol$branch]($style) ";
    };

    # Git 状态
    git_status = {
      format = "[$all]($style) ";
      style = "bold red";
      up_to_date = "[✓](bold green)";
    };

    # Nix Shell
    nix_shell = {
      symbol = "❄️ ";
      style = "bold blue";
      format = "[$symbol(nix-shell)]($style) ";
    };

    # 禁用不需要的模块
    package.disabled = true;
    time.disabled = true;
  };
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = settings;
    };
  };
}
