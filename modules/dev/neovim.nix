{ ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # 取消版本检查，加快构建速度
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 1. 🎨 主题配置：Carbonfox
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
      # --- 剪切板 ---
      clipboard = "unnamed,unnamedplus";
      
      # --- 缩进与排版 ---
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      list = true;
      listchars = "tab:▸ ,trail:·"; # 稍微优化了一下 listchars

      # --- 搜索 ---
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;
      wildmenu = true;

      # --- 界面体验 ---
      number = true;
      ruler = true;
      cursorline = true;
      wrap = true;
      linebreak = true;
      sidescroll = 1;
      laststatus = 2;
      history = 10000;
      backspace = "indent,eol,start";
      encoding = "utf-8";
      
      # --- 文件持久化 ---
      undofile = true;
      swapfile = true;
      backup = false;
      autoread = true;
      
      # 设定持久化文件的存储路径 (对应下方 Lua 逻辑)
      undodir = "/tmp/.nvim-undo"; # 临时占位，实际由 Lua 动态管理更安全
    };

    # ==========================================
    # 3. ⌨️ 快捷键与全局变量
    # ==========================================
    globals.mapleader = ";";

    keymaps = [
      {
        mode = "n";
        key = "<tab>";
        action = "<C-w>w";
        options.desc = "Window: Switch Focus";
      }
      {
        mode = "n";
        key = "<leader>r";
        action = "<C-r>";
        options.desc = "Edit: Redo";
      }
      # 补充一个常用的清除高亮快捷键
      {
        mode = "n";
        key = "<Esc>";
        action = ":nohlsearch<CR>";
        options = { silent = true; desc = "UI: Clear Highlight"; };
      }
    ];

    # ==========================================
    # 4. ⚡ 自动命令 (Auto Commands) - 核心优化区
    # ==========================================
    
    # 定义自动命令组，防止重复加载
    autoGroups = {
      restore_cursor = { clear = true; };
      markdown_fix = { clear = true; };
    };

    autoCmd = [
      # ✅ 功能实现：恢复上次退出时的光标位置
      {
        event = [ "BufReadPost" ];
        group = "restore_cursor";
        pattern = [ "*" ];
        callback = {
          __raw = ''
            function()
              -- 排除 gitcommit, gitrebase 等不需要记忆位置的文件类型
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
      
      # ✅ 功能实现：Markdown 渲染修复
      {
        event = [ "FileType" ];
        group = "markdown_fix";
        pattern = [ "markdown" ];
        callback = {
          __raw = ''
            function()
              -- 禁用原本的高亮错误显示
              vim.cmd("highlight link markdownError Normal")
              -- 针对特定终端环境的清理
              vim.cmd("highlight markdownError term=NONE cterm=NONE guifg=NONE")
            end
          '';
        };
      }
      
      # ✅ 功能实现：文件被外部修改时自动加载
      {
        event = [ "FocusGained" "BufEnter" ];
        pattern = [ "*" ];
        command = "checktime";
      }
    ];

    # ==========================================
    # 5. 📦 插件
    # ==========================================
    plugins = {
      nix.enable = true; 
      # 强烈建议开启 treesitter 以获得更好的高亮
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
    };

    # ==========================================
    # 6. 🛠️ Lua 初始化 (替代 Vimscript)
    # ==========================================
    extraConfigLua = ''
      -- 自动创建持久化目录 (Lua 版，比 Vimscript 更健壮)
      local state_dir = vim.fn.stdpath("state")
      local undo_dir = state_dir .. "/undo"
      local swap_dir = state_dir .. "/swap"

      if vim.fn.isdirectory(undo_dir) == 0 then
        vim.fn.mkdir(undo_dir, "p", 448) -- 0700 权限
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
