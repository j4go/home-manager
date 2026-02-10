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
        background = "hard";
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

      # 修正：Neovim 自动处理粘贴，不再需要 pastetoggle
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
    # ⌨️ 快捷键 (保留系统剪贴板映射)
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      {
        mode = "n";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Copy to System";
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

    # 修正：彻底删除 extraConfigVim 块中的 t_BE 等终端代码
    # Neovim 不支持这些选项，且会自动处理这些逻辑。

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
      # 修正：删除了 InsertLeave 里的 set nopaste，因为不再使用 paste 模式
    ];

    # ==========================================
    # 🛠️ Lua 专项优化
    # ==========================================
    extraConfigLua = ''
      -- 自动创建持久化目录
      local function ensure_dir(path)
        if vim.fn.isdirectory(path) == 0 then
          vim.fn.mkdir(path, "p", 448)
        end
      end
      ensure_dir(vim.fn.stdpath("state") .. "/undo")
    '';
  };
}
