{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      os.disabled = true;

      # 1️⃣ 重新排版 format：
      # 注意：我们将末尾圆弧直接挂载在模块的 format 结尾，而不是放在全局 format 末尾，
      # 这样无论哪个模块是最后一个，它都能自带正确的圆弧颜色。
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      username = {
        show_always = true;
        style_user = "bg:#4C566A fg:#ECEFF4 bold";
        format = "[](fg:#4C566A)[$user]($style)";
      };

      hostname = {
        ssh_only = true;
        style = "bg:#4C566A fg:#ECEFF4 bold";
        format = "[@$hostname]($style)";
      };

      directory = {
        style = "bg:#88C0D0 fg:#2E3440 bold";
        # 这里的 [](fg:#88C0D0) 是“保险丝”，如果后面没接 Git，它就负责收尾
        format = "[](fg:#4C566A bg:#88C0D0)[ $path ]($style)[](fg:#88C0D0)";
        truncation_length = 0;
        truncate_to_repo = false; # 设为 false，确保进入 git 仓库也不缩减路径
        truncation_symbol = ""; # 彻底禁用缩减标识
      };

      git_branch = {
        symbol = " ";
        style = "bg:#D08770 fg:#2E3440 bold";
        # 重点：前面的  背景色要接 directory 的 bg (#88C0D0)
        # 末尾带上圆弧 [](fg:#D08770)
        format = "[](fg:#88C0D0 bg:#D08770)[ $symbol$branch]($style)";
      };

      git_status = {
        style = "bg:#D08770 fg:#2E3440 bold";
        # 在 status 后面收尾
        format = "[$all_status$ahead_behind]($style)[](fg:#D08770)";
      };

      cmd_duration = {
        min_time = 500;
        style = "bg:#EBCB8B fg:#2E3440 bold";
        # 如果耗时模块显示，它会接在 git 的  后面，所以这里要用  覆盖掉前面的圆弧
        format = "[](fg:#D08770 bg:#EBCB8B)[  $duration ]($style)[](fg:#EBCB8B)";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
