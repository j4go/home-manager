{
  pkgs,
  lib,
  ...
}: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$conda"
        "$python"
        "$line_break"
        "$character"
      ];
      os.disabled = true;
      hostname = {
        ssh_only = true;
        format = "[$hostname]($style) ";
        style = "bold green";
      };
      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        style = "bold cyan";
      };
      conda = {
        symbol = "󱆠 ";
        format = "via [$symbol$environment]($style) ";
        style = "bold dim magenta";
      };
      python = {
        symbol = "🐍 ";
        format = "[$symbol($version )]($style)";
        style = "bold yellow";
        detect_files = ["pyproject.toml" "requirements.txt"];
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
