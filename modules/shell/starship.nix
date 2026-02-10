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
      # =========================================================
      # 1. 核心布局
      # =========================================================
      # 结构：[身份 > 路径]  [Git]  [耗时]
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

      # 保持行尾留空，把耗时放进主 format 里，作为浮动胶囊
      right_format = "";
      add_newline = true;

      # =========================================================
      # 2. 身份 + 路径 (融合胶囊)
      # 颜色逻辑：身份(深灰) -> 箭头 -> 路径(蓝色)
      # =========================================================

      # 2.1 身份：深灰底，白字，左圆头，去掉了Icon
      username = {
        show_always = true;
        style_user = "bg:#4C566A fg:#ECEFF4 bold";
        style_root = "bg:#4C566A fg:#BF616A bold";
        format = "[](fg:#4C566A)[$user]($style)"; # 只有圆头和名字
      };

      # 2.2 主机名：跟用户名共用背景，实现无缝连接
      hostname = {
        ssh_only = true;
        style = "bg:#4C566A fg:#ECEFF4 bold";
        format = "[@$hostname]($style)"; # 去掉了 ssh icon，纯文字
      };

      # 2.3 路径：蓝底，黑字，右圆头
      # 关键点：开头是[](前景色=上一块背景, 背景色=当前背景)
      # 结尾是[]，确保它是圆润结束，不是尖的
      directory = {
        style = "bg:#88C0D0 fg:#2E3440 bold";
        format = "[](fg:#4C566A bg:#88C0D0)[ $path ]($style)[](fg:#88C0D0) ";
        truncation_length = 3;
        truncate_to_repo = false;
      };

      # =========================================================
      # 3. Git (独立悬浮胶囊)
      # 只有存在 Git 仓库时才显示，显示就是完整的圆角胶囊
      # =========================================================
      git_branch = {
        symbol = " ";
        style = "bg:#D08770 fg:#2E3440 bold";
        # 独立的 [ ... ] 结构
        format = "[](fg:#D08770)[ $symbol$branch ]($style)[](fg:#D08770) ";
      };

      git_status = {
        style = "bg:#D08770 fg:#2E3440 bold";
        # Status 如果有，紧贴着 Branch 显示，或者你可以让它变成纯符号
        format = "[$all_status$ahead_behind ]($style)";
      };

      # =========================================================
      # 4. 耗时 (独立悬浮胶囊)
      # 只有超过时间才显示，不会留下空色块
      # =========================================================
      cmd_duration = {
        min_time = 1000;
        style = "bg:#EBCB8B fg:#2E3440 bold";
        format = "[](fg:#EBCB8B)[  $duration ]($style)[](fg:#EBCB8B) ";
      };

      # =========================================================
      # 5. 符号与系统修复
      # =========================================================
      os = {disabled = true;}; # 彻底禁用 OS 模块，防止 icon 干扰

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✖](bold red)";
      };
    };
  };
}
