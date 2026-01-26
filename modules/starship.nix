{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    
    # ✅ 自动集成到 Shell
    enableBashIntegration = true;
    enableZshIntegration = true;

    # ✅ 详细配置 (映射到 starship.toml)
    settings = {
      # 提示符之间不换行 (紧凑模式)
      add_newline = false;

      # 符号映射 (需 Nerd Font 支持，见文末说明)
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      # 📦 模块配置：Git
      git_branch = {
        symbol = "🌱 ";
        truncation_length = 10;
        truncation_symbol = "";
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

      # 📦 模块配置：语言环境 (按需显示)
      package.disabled = true; # 禁用通用包版本显示，避免太乱
      
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
