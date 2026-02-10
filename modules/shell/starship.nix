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

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$cmd_duration"
        "[ ](fg:current_bg)"
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
        format = "[](fg:#4C566A bg:#88C0D0)[ $path ]($style)";
        truncation_length = 0; # 保持完整路径
        fish_style_pwd_dir_length = 0;
      };

      git_branch = {
        symbol = " ";
        style = "bg:#D08770 fg:#2E3440 bold";
        format = "[](fg:#88C0D0 bg:#D08770)[ $symbol$branch]($style)";
      };

      git_status = {
        style = "bg:#D08770 fg:#2E3440 bold";
        format = "[$all_status$ahead_behind ]($style)";
      };

      cmd_duration = {
        min_time = 500;
        style = "bg:#EBCB8B fg:#2E3440 bold";
        format = "[](fg:#D08770 bg:#EBCB8B)[  $duration ]($style)";
      };
    };
  };
}
