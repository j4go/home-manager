#                           _
#    ____  ___  ____ _   __(_)___ ___
#   / __ \/ _ \/ __ \ | / / / __ `__ \
#  / / / /  __/ /_/ / |/ / / / / / / /
# /_/ /_/\___/\____/|___/_/_/ /_/ /_/
#
{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # ==========================================
    # 📦 外部依赖注入
    # ==========================================
    extraPackages = [pkgs.figlet];

    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 🎨 主题配置：Everforest
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        background = "medium";
        enable_italic = 1;
        transparent_background = 1;
      };
    };

    # ==========================================
    # ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      background = "dark";
      termguicolors = true;

      # --- 粘贴与乱码修复核心配置 ---
      # 1. 允许粘贴模式切换快捷键（F2）
      pastetoggle = "<F2>";
      # 2. 确保自动缩进在粘贴模式下会被正确禁用
      autoindent = true;
      smartindent = true;

      # 界面显示
      showmode = false;
      showtabline = 1;
      laststatus = 2;
      number = true;
      cursorline = true;

      # 缩进与排版
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;

      # 搜索
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;

      # 持久化
      undofile = true;
      timeoutlen = 600;
    };

    # ==========================================
    # ⌨️ 快捷键
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      # 系统剪贴板交互 (利用 "+ 寄存器)
      {
        mode = "n";
        key = "y";
        action = "\"+yy";
        options.desc = "Copy Line to System";
      }
      {
        mode = "v";
        key = "y";
        action = "\"+y";
        options.desc = "Copy Selection to System";
      }
      {
        mode = "n";
        key = "p";
        action = "\"+p";
        options.desc = "Paste from System";
      }
      {
        mode = "n";
        key = "<leader>l"; # 假设这是你的 UI 增强映射
        action = ":nohlsearch<CR>";
        options.silent = true;
      }
      {
        mode = "n";
        key = "x";
        action = "\"_x";
        options.desc = "Delete char without copying";
      }
    ];

    # ==========================================
    # 📦 插件配置
    # ==========================================
    plugins = {
      nix.enable = true;
      treesitter.enable = true;

      lightline = {
        enable = true;
        settings = {
          colorscheme = "everforest";
          active = {
            left = [
              ["mode" "paste"] # 状态栏会显示当前是否处于 -- PASTE -- 模式
              ["readonly" "filename" "modified"]
            ];
          };
        };
      };
    };

    # ==========================================
    # 🛠️ 额外底层配置 (处理 SSH 粘贴协议)
    # ==========================================
    extraConfigVim = ''
      " 自动识别终端粘贴开始/结束序列 (Bracketed Paste Mode)
      if &term =~ "xterm" || &term =~ "screen" || &term =~ "tmux"
          let &t_BE = "\<Esc>[?2004h"
          let &t_BD = "\<Esc>[?2004l"
          let &t_PS = "\<Esc>[200~"
          let &t_PE = "\<Esc>[201~"
      endif
    '';

    # ==========================================
    # ⚡ 自动命令
    # ==========================================
    autoCmd = [
      {
        event = ["InsertLeave"];
        pattern = ["*"];
        command = "set nopaste"; # 退出插入模式时自动关闭粘贴模式，防止误操作
      }
    ];
  };
}
