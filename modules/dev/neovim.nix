{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # 取消版本检查，加快构建速度
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 1. 🎨 主题配置：Carbonfox (与 Tomorrow-Night 风格相近)
    # ==========================================
    colorschemes.nightfox = {
      enable = true;
      flavor = "carbonfox";
      settings = {
        options = {
          transparent = false;
          terminal_colors = true;
          styles = {
            comments = "italic";
            keywords = "bold";
            functions = "NONE";
          };
        };
      };
    };

    # ==========================================
    # 2. ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      # --- 🚀 [优化] 剪切板策略变更 ---
      # 移除全局 clipboard = "unnamedplus"。
      # 理由：Linux 下频繁调用外部 xclip 会导致卡顿。
      # 现在采用“显式交互”策略，只有按 ;;y 时才调用系统剪切板。
      clipboard = "";

      # --- 缩进与排版 ---
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true; # 默认转为空格，下方有针对 Make/Go 的特例覆盖
      autoindent = true;
      list = true;
      listchars = "tab:▸ ,trail:·";

      # --- 搜索 ---
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;
      wildmenu = true;

      # --- 界面体验 ---
      number = true;
      ruler = true;
      cursorline = true; # 默认开启，下方 AutoCmd 会动态切换
      wrap = true;
      linebreak = true;
      sidescroll = 1;
      laststatus = 2;
      history = 10000;
      backspace = "indent,eol,start";
      encoding = "utf-8";

      # 按键超时 ---
      # 对应 .vimrc 的 set timeoutlen=600
      timeoutlen = 600;

      # --- 文件持久化 ---
      undofile = true;
      swapfile = true;
      backup = false;
      autoread = true;

      # 设定持久化文件的存储路径 (对应下方 Lua 逻辑)
      undodir = "/tmp/.nvim-undo";
    };

    # ==========================================
    # 3. ⌨️ 快捷键与全局变量
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      # === 系统剪贴板交互 (Explicit Clipboard) ===
      {
        mode = "n";
        key = "<leader><leader>y";
        action = "\"+yy";
        options.desc = "Clipboard: Copy Line to System";
      }
      {
        mode = "v";
        key = "<leader><leader>y";
        action = "\"+y";
        options.desc = "Clipboard: Copy Selection to System";
      }
      {
        mode = "n";
        key = "<leader><leader>a";
        action = ":%y+<CR>";
        options.desc = "Clipboard: Copy Whole File to System";
      }
      {
        mode = "n";
        key = "<leader><leader>p";
        action = "\"+p";
        options.desc = "Clipboard: Paste from System";
      }

      # === 导航与翻页 (Ctrl Key Alias) ===
      {
        mode = "n";
        key = "<leader>d";
        action = "<C-d>";
        options.desc = "Nav: Half Page Down";
      }
      {
        mode = "n";
        key = "<leader>u";
        action = "<C-u>";
        options.desc = "Nav: Half Page Up";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<C-f>";
        options.desc = "Nav: Page Down";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<C-b>";
        options.desc = "Nav: Page Up";
      }

      {
        mode = "n";
        key = "<leader>r";
        action = "<C-r>";
        options.desc = "Edit: Redo";
      }
      {
        mode = "n";
        key = "<Esc>";
        action = ":nohlsearch<CR><Esc>"; # 末尾 <Esc> 防御性清除
        options = {
          silent = true;
          desc = "UI: Clear Highlight";
        };
      }
      # x 使用黑洞寄存器
      {
        mode = "n";
        key = "x";
        action = "\"_x";
        options.desc = "Delete char without copying (Speedup)";
      }
    ];

    # ==========================================
    # 4. ⚡ 自动命令 (Auto Commands)
    # ==========================================

    autoGroups = {
      restore_cursor = {clear = true;};
      markdown_fix = {clear = true;};
      smart_cursorline = {clear = true;};
      indent_fix = {clear = true;};
    };

    autoCmd = [
      # 智能 Cursorline (Smart Cursorline)
      # 目的：输入时关闭高亮减少延迟，浏览时开启高亮方便定位
      {
        event = ["InsertEnter" "WinLeave"];
        group = "smart_cursorline";
        pattern = ["*"];
        command = "set nocursorline";
      }
      {
        event = ["InsertLeave" "WinEnter"];
        group = "smart_cursorline";
        pattern = ["*"];
        command = "set cursorline";
      }

      # 目的：Makefile 和 Go 必须使用真实 Tab，不能转空格
      {
        event = ["FileType"];
        group = "indent_fix";
        pattern = ["make" "go"];
        command = "setlocal noexpandtab";
      }

      # 恢复上次退出时的光标位置
      {
        event = ["BufReadPost"];
        group = "restore_cursor";
        pattern = ["*"];
        callback = {
          __raw = ''
            function()
              if vim.bo.ft ~= 'gitcommit' and vim.bo.ft ~= 'gitrebase' then
                local mark = vim.api.nvim_buf_get_mark(0, '"')
                local lcount = vim.api.nvim_buf_line_count(0)
                if mark[1] > 0 and mark[1] <= lcount then
                  pcall(vim.api.nvim_win_set_cursor, 0, mark)
                end
              end
            end
          '';
        };
      }

      # Markdown 渲染修复
      {
        event = ["FileType"];
        group = "markdown_fix";
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

      # 文件被外部修改时自动加载
      {
        event = ["FocusGained" "BufEnter"];
        pattern = ["*"];
        command = "checktime";
      }
    ];

    # ==========================================
    # 5. 📦 插件
    # ==========================================
    plugins = {
      nix.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
    };

    # ==========================================
    # 6. 🛠️ Lua 初始化 (替代 Vimscript)
    # ==========================================
    extraConfigLua = ''
      -- 自动创建持久化目录
      local state_dir = vim.fn.stdpath("state")
      local undo_dir = state_dir .. "/undo"
      local swap_dir = state_dir .. "/swap"

      if vim.fn.isdirectory(undo_dir) == 0 then
        vim.fn.mkdir(undo_dir, "p", 448)
      end

      if vim.fn.isdirectory(swap_dir) == 0 then
        vim.fn.mkdir(swap_dir, "p", 448)
      end

      -- 强制应用设置
      vim.opt.undodir = undo_dir
      vim.opt.directory = swap_dir .. "//"

      -- Markdown 全局变量配置
      vim.g.markdown_disable_html = 1
      vim.g.markdown_exclude_embed = 1
      vim.g.markdown_disable_flow = 1
    '';
  };
}
