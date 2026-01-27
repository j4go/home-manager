{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      command_timeout = 2000;
      add_newline = false;
      line_break.disabled = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };
      git_branch = {
        symbol = "🌱 ";
        truncation_length = 10;
      };
      git_status = {
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++\($count\)](green)";
        renamed = "👅";
        deleted = "🗑";
      };
      package.disabled = true;
      nodejs = {
        symbol = "⬢ ";
        style = "bold green";
      };
      golang = {
        symbol = "🐹 ";
        style = "bold cyan";
      };
      python = {
        symbol = "🐍 ";
      };
    };
  };
}
