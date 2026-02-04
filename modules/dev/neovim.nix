{...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # 取消版本检查，加快构建速度
    version.enableNixpkgsReleaseCheck = false;

    # ==========================================
    # 🎨 主题配置：Everforest Light (与 Mac 保持一致)
    # "Everforest Light 的三种“口味”对比
    # Everforest 的魅力在于它不提供单一的白色，而是通过调节背景的“有机感”来适应不同的环境光线。

    # 对比度等级    背景色特征         视觉感受                              适用场景
    # Hard          较冷的象牙白       清晰度最高；文字跳跃感强              强光环境；需要极高辨识度时
    # Medium        温暖的米黄色       最平衡的视觉体验；经典Everforest感    日常办公；全天候使用
    # Soft          带有绿色调的暗白   极度柔和；几乎没有视觉刺激            眼睛易疲劳者；长时间逻辑思考
    # ==========================================
    colorschemes.everforest = {
      enable = true;
      settings = {
        # background 指的是对比度 (Contrast)，接受 "hard", "medium", "soft"
        background = "medium";
        enable_italic = 1; # 开启斜体
        # 关闭性能优化模式以消除底部提示
        better_performance = 0;
        # 开启 Everforest 原生透明背景支持
        # 这会告诉主题不要绘制 Normal 层的背景色
        transparent_background = 1;
      };
    };

    # ==========================================
    # ⚙️ 基础选项 (Opts)
    # ==========================================
    opts = {
      #background = "light";
      background = "dark";
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
    # ⚡ 自动命令 (与 Mac 逻辑一致)
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

      # 有时候主题设置了 transparent 依然会有残留 (如行号栏)，这个自动命令会在加载后再次清除
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
    ];

    # ==========================================
    # 🛠️ Lua 专项优化
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
