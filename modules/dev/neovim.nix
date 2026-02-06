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
    # 确保 figlet 在 Neovim 的 PATH 中可用，
    # 这样无论系统层是否安装，插件都能正常工作。
    extraPackages = [pkgs.figlet];

    # 取消版本检查，加快构建速度
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 🎨 主题配置：Everforest Light (与 Mac 保持一致)
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        background = "medium";
        enable_italic = 1;
        better_performance = 0;
        transparent_background = 1;
      };
    };

    # ==========================================
    # ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      background = "dark"; # 您配置中显式覆盖为 dark
      termguicolors = true;

      # 界面显示优化
      showmode = false;
      showtabline = 1;
      laststatus = 2;

      # 剪切板策略
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
    # ⌨️ 快捷键 (完全对齐 Mac)
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
    # 4. 📦 插件配置
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
              ["mode" "paste"]
              ["readonly" "filename" "modified"]
            ];
          };
        };
      };
    };

    # ==========================================
    # ⚡ 自动命令
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
      # 透明背景残留清除
      {
        event = ["VimEnter" "ColorScheme"];
        callback = {
          __raw = ''
            function()
              vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
              vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
              vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
              vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
              vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
            end
          '';
        };
      }
      # 命令行窗口检测
      {
        event = ["FocusGained" "BufEnter" "CursorHold"];
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              if vim.fn.getcmdwintype() == "" then
                vim.cmd("checktime")
              end
            end
          '';
        };
      }
      # 终端体验优化
      {
        event = ["TermOpen"];
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              vim.cmd("startinsert")
              vim.opt_local.number = false
              vim.opt_local.relativenumber = false
              vim.opt_local.signcolumn = "no"
            end
          '';
        };
      }
    ];

    # ==========================================
    # 🛠️ Lua 专项优化 & 自定义函数
    # ==========================================
    extraConfigLua = ''

      -- 1. Markdown 全局变量
      vim.g.markdown_disable_html = 1
      vim.g.markdown_exclude_embed = 1
      vim.g.markdown_disable_flow = 1

      -- 2. 自动创建持久化目录
      local function ensure_dir(path)
        if vim.fn.isdirectory(path) == 0 then
          vim.fn.mkdir(path, "p", 448)
        end
      end
      ensure_dir(vim.fn.stdpath("state") .. "/undo")


      -- ==========================================
      -- 🎨 Figlet 自动化 ASCII 标题系统
      -- ==========================================

      -- 1. 定义核心处理函数 (接收 文本 和 字体参数)
      local function generate_figlet(text, font_arg)
          if text == "" then return end

          -- 获取当前 buffer 的注释符 (默认 # %s)
          local cms = vim.bo.commentstring
          if cms == "" then cms = "# %s" end

          -- 构造命令: figlet [字体参数] "文本"
          -- 注意：font_arg 默认为空字符串
          font_arg = font_arg or ""
          local cmd = string.format("figlet -w 1000 %s %s", font_arg, vim.fn.shellescape(text))

          -- 执行命令
          local handle = io.popen(cmd)
          local result = handle:read("*a")
          handle:close()

          -- 转换为行表并添加注释
          local lines = {}
          for line in result:gmatch("[^\r\n]+") do
              local cleaned_line = line:gsub("%s+$", "")
              table.insert(lines, (cms:gsub("%%s", cleaned_line)))
          end

          -- 在当前光标处插入
          local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
          vim.api.nvim_buf_set_lines(0, row, row, false, lines)
      end

      -- ==========================================
      -- 注册命令 (必须大写开头！)
      -- ==========================================

      -- 1. 标准字体 (对应原来的 print_big)
      -- 使用: :Figlet Hello
      vim.api.nvim_create_user_command("Figlet", function(opts)
          generate_figlet(opts.args, "")
      end, { nargs = 1 })

      -- 2. 斜体字 (对应原来的 print / slant)
      -- 使用: :FigletSlant Hello
      vim.api.nvim_create_user_command("FigletSlant", function(opts)
          generate_figlet(opts.args, "-f slant")
      end, { nargs = 1 })

      -- 3. 小字体 (对应原来的 print_small)
      -- 使用: :FigletSmall Hello
      vim.api.nvim_create_user_command("FigletSmall", function(opts)
          generate_figlet(opts.args, "-f small")
      end, { nargs = 1 })

      -- ==========================================
      -- 快捷键绑定
      -- ==========================================

      -- <leader>fg 默认使用斜体 (你可以根据喜好改成 :Figlet 或 :FigletSmall)
      vim.keymap.set("n", "<leader>fg", ":FigletSlant ", { desc = "ASCII Title (Slant)" })

    '';
  };
}
