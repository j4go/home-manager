{pkgs, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    version.enableNixpkgsReleaseCheck = false;
    # 显式注入系统剪贴板驱动
    extraPackages = with pkgs; [
      wl-clipboard # Wayland
      xclip # X11
    ];
    # ==========================================
    # 主题配置：Everforest
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
    # 基础选项 (Opts)
    # ==========================================
    opts = {
      termguicolors = true;

      # 混合行号：当前行显示绝对行号，其他行显示相对行号，极大提升跳转效率
      number = true;
      relativenumber = true;

      cursorline = true;
      showmode = false; # Lualine 已显示模式，原生状态栏模式可禁用

      # 缩进与排版
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      smartindent = false;

      # 搜索
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;

      # 持久化与体验
      undofile = true;

      # 缩短延迟，提升快捷键响应感
      timeoutlen = 300;
    };

    # 业界标准已转向使用 <Space> 作为 Leader
    globals.mapleader = " ";
    keymaps = [
      # 系统剪贴板交互
      {
        mode = "n";
        key = "<leader>y";
        action = "\"+y";
        options.desc = "Copy to System";
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
        key = "<leader>ya";
        action = ":%y+<CR>";
        options = {
          desc = "Copy whole file to System Clipboard";
          silent = true;
        };
      }

      # Telescope 快捷键
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find Files";
      }
      {
        mode = "n";
        key = "<leader>fg";
        action = "<cmd>Telescope live_grep<CR>";
        options.desc = "Live Grep";
      }
      {
        mode = "n";
        key = "<leader>fb";
        action = "<cmd>Telescope buffers<CR>";
        options.desc = "Find Buffers";
      }

      # 辅助操作 按ESC清除当前的搜索高亮
      {
        mode = "n";
        key = "<Esc>";
        action = ":nohlsearch<CR><Esc>";
        options.silent = true;
      }
    ];

    # ==========================================
    # 插件配置 (Plugins)
    # ==========================================
    plugins = {
      # 显式启用图标支持
      web-devicons.enable = true;

      # 语法高亮引擎增强
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
        settings.indent.enable = true;
      };

      # 替换 lightline 为更现代的 lualine
      lualine = {
        enable = true;
        settings.options.theme = "everforest";
      };

      # 模糊搜索核心
      telescope.enable = true;

      # LSP 语言服务
      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true; # Nix 语言支持
          bashls.enable = true; # Bash 支持
        };
      };

      # 自动补全引擎
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            {name = "nvim_lsp";}
            {name = "path";}
            {name = "buffer";}
          ];
          mapping = {
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
          };
        };
      };
    };

    # ==========================================
    # 自动命令 (AutoCmd)
    # ==========================================
    autoCmd = [
      # 恢复上次退出位置
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
  };
}
