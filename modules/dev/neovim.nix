{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 主题配置：Everforest
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        # 这里的 background 指对比度，不是全局选项，不会报错
        background = "hard";
        enable_italic = 1;
        better_performance = 1;
        transparent_background = 1;
      };
    };

    # ==========================================
    # 基础选项 (Opts)
    # ==========================================
    opts = {
      termguicolors = true;

      # 禁用 smartindent 防止粘贴出现“阶梯效应”
      smartindent = false;
      # 保持基础自动缩进即可
      autoindent = true;

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

      # 持久化与体验
      undofile = true;
      timeoutlen = 600;
      clipboard = "unnamedplus"; # 尝试与系统剪贴板同步
    };

    # ==========================================
    # 快捷键 (Leader = ;)
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      # 系统剪贴板交互
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
        mode = "n";
        key = "<leader>ya";
        action = ":%y+<CR>";
        options = {
          desc = "Copy whole file to System Clipboard";
          silent = true;
        };
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
    # 插件配置
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
    # 自动命令
    # ==========================================
    autoCmd = [
      # 恢复上次退出时的光标位置
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
    ];

    # ==========================================
    # Lua 专项优化
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
