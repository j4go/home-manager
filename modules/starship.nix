{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    
    # 自动集成到 Shell
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      # 1. 禁用提示符前的空行 (紧凑模式)
      add_newline = false;

      # 2. 🚀 关键修复：禁用换行符模块，强制单行显示
      line_break.disabled = true;

      # 3. 符号映射
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      # 4. Git 配置
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

      # 5. 语言环境配置
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
