{
  config,
  lib,
  ...
}: let
  cfg = config.myOptions.shell.starship;
  # 定义颜色变量，方便统一修改
  colors = {
    bg0 = "#3B4252"; # 深灰蓝 (Nord风格)
    bg1 = "#81A1C1"; # 浅蓝
    bg2 = "#88C0D0"; # 青蓝
    bg3 = "#4C566A"; # 中灰
    fg0 = "#ECEFF4"; # 近白
  };
in {
  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        # 核心格式：使用 [内容](style) 语法来实现背景色块
        # 注意模块间的 [](bg:next_color fg:this_color) 是实现平滑过渡的关键
        format = lib.concatStrings [
          "[](${colors.bg1})"
          "$username"
          "$hostname"
          "[](bg:${colors.bg2} fg:${colors.bg1})"
          "$directory"
          "[](bg:${colors.bg0} fg:${colors.bg2})"
          "$git_branch"
          "$git_status"
          "[](bg:${colors.bg3} fg:${colors.bg0})"
          "$nix_shell"
          "[](fg:${colors.bg3})"
          "$line_break"
          "$character"
        ];

        # 将耗时放在右侧，保持主行清爽
        right_format = ''[](fg:${colors.bg3})$cmd_duration[](fg:${colors.bg3})'';

        directory = {
          style = "bg:${colors.bg2} fg:${colors.bg0} bold";
          format = "[$path]($style)";
          truncation_length = 3;
          fish_style_pwd_dir_length = 1;
        };

        username = {
          show_always = true;
          style_user = "bg:${colors.bg1} fg:${colors.bg0} bold";
          style_root = "bg:${colors.bg1} fg:red bold";
          format = "[$user]($style)";
        };

        hostname = {
          ssh_only = true;
          style = "bg:${colors.bg1} fg:${colors.bg0} bold";
          format = "[@$hostname]($style)";
        };

        git_branch = {
          symbol = " ";
          style = "bg:${colors.bg0} fg:${colors.bg2} bold";
          format = "[[ $symbol$branch ]($style)]($style)";
        };

        git_status = {
          style = "bg:${colors.bg0} fg:${colors.bg2}";
          format = "[($all_status$ahead_behind )($style)]($style)";
        };

        nix_shell = {
          symbol = "❄️ ";
          style = "bg:${colors.bg3} fg:${colors.bg2} bold";
          format = "[[ $symbol$state ]($style)]($style)";
        };

        cmd_duration = {
          min_time = 500;
          style = "bg:${colors.bg3} fg:${colors.fg0}";
          format = "[  $duration ]($style)";
        };

        character = {
          success_symbol = "[ ➜](bold green)";
          error_symbol = "[ ✖](bold red)";
        };

        # 辅助设置
        add_newline = true;
        line_break.disabled = false;
      };
    };
  };
}
