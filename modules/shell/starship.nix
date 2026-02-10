{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.myOptions.shell.starship;
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;

      settings = {
        # -------------------------------------------------------------------------
        # 1. 核心格式控制 (Powerline 胶囊风格)
        # -------------------------------------------------------------------------
        format = lib.concatStrings [
          "[](fg:#89b4fa)"
          "$username"
          "$hostname"
          "[](bg:#a6e3a1 fg:#89b4fa)"
          "$directory"
          "[](bg:#313244 fg:#a6e3a1)"
          "$git_branch"
          "$git_status"
          "[](bg:#fab387 fg:#313244)"
          "$nix_shell"
          "[](fg:#fab387)"
          "$line_break"
          "$character"
        ];

        # 右侧格式：执行耗时
        right_format = "[](fg:#cba6f7)$cmd_duration[](fg:#cba6f7)";

        add_newline = true;
        command_timeout = 1000;

        # -------------------------------------------------------------------------
        # 2. 目录模块 (完整显示，无缩写)
        # -------------------------------------------------------------------------
        directory = {
          style = "bg:#a6e3a1 fg:#11111b bold";
          format = "[ $path ]($style)";
          truncation_length = 0;
          truncate_to_repo = false;
          fish_style_pwd_dir_length = 0;
        };

        # -------------------------------------------------------------------------
        # 3. 用户与主机
        # -------------------------------------------------------------------------
        username = {
          show_always = true;
          style_user = "bg:#89b4fa fg:#11111b bold";
          style_root = "bg:#89b4fa fg:#f38ba8 bold";
          format = "[$user]($style)";
        };

        hostname = {
          ssh_only = true;
          style = "bg:#89b4fa fg:#11111b bold";
          format = "[@$hostname]($style)";
        };

        # -------------------------------------------------------------------------
        # 4. Git 模块
        # -------------------------------------------------------------------------
        git_branch = {
          symbol = " ";
          style = "bg:#313244 fg:#89dceb bold";
          format = "[[ $symbol$branch ]($style)]($style)";
        };

        git_status = {
          style = "bg:#313244 fg:#f38ba8";
          format = "[[($all_status$ahead_behind )]($style)]($style)";
          up_to_date = "[✓](bg:#313244 fg:#a6e3a1)";
        };

        # -------------------------------------------------------------------------
        # 5. Nix Shell 环境
        # -------------------------------------------------------------------------
        nix_shell = {
          symbol = "❄️ ";
          style = "bg:#fab387 fg:#11111b bold";
          format = "[[ $symbol$state ]($style)]($style)";
        };

        # -------------------------------------------------------------------------
        # 6. 命令执行耗时
        # -------------------------------------------------------------------------
        cmd_duration = {
          min_time = 500;
          style = "bg:#cba6f7 fg:#11111b bold";
          format = "[  $duration ]($style)";
        };

        # -------------------------------------------------------------------------
        # 7. 提示符字符
        # -------------------------------------------------------------------------
        character = {
          success_symbol = "[ ➜](bold #a6e3a1)";
          error_symbol = "[ ✖](bold #f38ba8)";
        };

        package.disabled = true;
        time.disabled = true;
      };
    };
  };
}
