{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # 📦 外部依赖
    extraPackages = [pkgs.figlet];
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 🎨 主题配置：Everforest
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        background = "hard"; # 已确认：此配置不会触发 E519 错误
        enable_italic = 1;
        better_performance = 1;
        transparent_background = 1;
      };
    };

    # ==========================================
    # ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      termguicolors = true;

      # 粘贴优化
      pastetoggle = "<F2>";
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
    # ⌨️ 快捷键 (优化：不破坏原生 y 动作)
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      # 使用 <leader>y 交互系统剪贴板，保留原生 y 键用于普通复制
      {
        mode = "n";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Copy motion to System";
      }
      {
        mode = "n";
        key = "<leader>yy";
        action = "\"+yy";
        options.desc = "Copy Line to System";
      }
      {
        mode = "v";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Copy Selection to System";
      }
      {
        mode = "n";
        key = "<leader>p";
        action = "\"+p";
        options.desc = "Paste from System";
      }
      # UI 增强
      {
        mode = "n";
        key = "<Esc>";
        action = ":nohlsearch<CR><Esc>";
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
          active.left = [
            ["mode" "paste"]
            ["readonly" "filename" "modified"]
          ];
        };
      };
    };

    # ==========================================
    # ⚡ 自动命令
    # ==========================================
    autoCmd = [
      # 1. 恢复光标位置
      {
        event = ["BufReadPost"];
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              local mark = vim.api.nvim_buf_get_mark(0, '"')
              local lcount = vim.api.nvim_buf_line_count(0)
              if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
              end
            end
          '';
        };
      }
      # 2. 退出插入模式自动关闭粘贴模式
      {
        event = ["InsertLeave"];
        pattern = ["*"];
        command = "set nopaste";
      }
    ];

    # ==========================================
    # 🛠️ Lua 专项优化 (自动创建目录)
    # ==========================================
    extraConfigLua = ''
      -- 自动创建持久化目录 (undo 等)
      local function ensure_dir(path)
        if vim.fn.isdirectory(path) == 0 then
          vim.fn.mkdir(path, "p", 448)
        end
      end
      ensure_dir(vim.fn.stdpath("state") .. "/undo")
    '';
  };
}
