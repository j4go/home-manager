{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # 取消版本检查，加快构建速度
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 1. 🎨 主题配置：Everforest Light (与 Mac 保持一致)
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        # background 指的是对比度 (Contrast)，接受 "hard", "medium", "soft"
        background = "medium";
        enable_italic = 1; # 开启斜体
        # 关闭性能优化模式以消除底部提示
        better_performance = 0;
      };
    };

    # ==========================================
    # 2. ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      # 浅色模式核心设置
      background = "light";
      termguicolors = true;

      # 界面显示优化
      showmode = false; # 隐藏原生 -- INSERT -- (交给 Lightline)
      showtabline = 1; # 只有多个标签页时才显示顶部标签栏 (解决 No Name 烦恼)
      laststatus = 2; # 始终显示状态栏

      # 剪切板策略：Linux 下显式交互防止卡顿
      clipboard = "";

      # 缩进与排版
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      list = true;
      listchars = "tab:▸ ,trail:·";

      # 搜索
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;

      # 体验与持久化
      number = true;
      cursorline = true;
      timeoutlen = 600;
      undofile = true;
      swapfile = true;
      backup = false;
      autoread = true;
    };

    # ==========================================
    # 3. ⌨️ 快捷键 (完全对齐 Mac)
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      # 系统剪贴板交互
      {
        mode = "n";
        key = "<leader><leader>y";
        action = "\"+yy";
        options.desc = "Copy Line to System";
      }
      {
        mode = "v";
        key = "<leader><leader>y";
        action = "\"+y";
        options.desc = "Copy Selection to System";
      }
      {
        mode = "n";
        key = "<leader><leader>a";
        action = ":%y+<CR>";
        options.desc = "Copy Whole File";
      }
      {
        mode = "n";
        key = "<leader><leader>p";
        action = "\"+p";
        options.desc = "Paste from System";
      }

      # 导航与翻页
      {
        mode = "n";
        key = "<leader>d";
        action = "<C-d>";
      }
      {
        mode = "n";
        key = "<leader>u";
        action = "<C-u>";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<C-f>";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<C-b>";
      }
      {
        mode = "n";
        key = "<leader>r";
        action = "<C-r>";
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
    # 4. 📦 插件配置 (新增 Lightline)
    # ==========================================
    plugins = {
      nix.enable = true;
      treesitter.enable = true;

      # 状态栏插件：Lightline
      lightline = {
        enable = true;
        settings = {
          colorscheme = "everforest";
          active = {
            left = [
              ["mode" "paste"]
              ["readonly" "filename" "modified"]
            ];
          };
        };
      };
    };

    # ==========================================
    # 5. ⚡ 自动命令 (与 Mac 逻辑一致)
    # ==========================================
    autoCmd = [
      # 智能 Cursorline
      {
        event = ["InsertEnter" "WinLeave"];
        command = "set nocursorline";
      }
      {
        event = ["InsertLeave" "WinEnter"];
        command = "set cursorline";
      }
      # Makefile/Go 缩进修复
      {
        event = ["FileType"];
        pattern = ["make" "go"];
        command = "setlocal noexpandtab";
      }
      # Markdown 报错块消除
      {
        event = ["FileType"];
        pattern = ["markdown"];
        callback = {
          __raw = ''
            function()
              vim.cmd("highlight link markdownError Normal")
              vim.cmd("highlight markdownError term=NONE cterm=NONE guifg=NONE")
            end
          '';
        };
      }
    ];

    # ==========================================
    # 6. 🛠️ Lua 专项优化
    # ==========================================
    extraConfigLua = ''
      -- Markdown 全局变量
      vim.g.markdown_disable_html = 1
      vim.g.markdown_exclude_embed = 1
      vim.g.markdown_disable_flow = 1

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
