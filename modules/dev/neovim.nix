{ ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    version.enableNixpkgsReleaseCheck = false;

    # 1. 🎨 主题配置：Carbonfox
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
            conditionals = "NONE";
            constants = "NONE";
          };
        };
      };
    };

    # 2. ⚙️ 基础选项 (Opts)
    opts = {
      # 剪切板
      clipboard = "unnamed,unnamedplus";
      
      # 缩进与排版
      tabstop = 4;
      softtabstop = 4;
      shiftwidth = 4;
      expandtab = true;
      autoindent = true;
      list = true;
      listchars = "tab:▸ ";

      # 搜索
      hlsearch = true;
      incsearch = true;
      ignorecase = true;
      smartcase = true;
      wildmenu = true;

      # 界面体验
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
      
      # 文件持久化
      undofile = true;
      swapfile = true;
      backup = false;
      autoread = true;
    };

    # 3. ⌨️ 快捷键与全局变量
    globals.mapleader = ";";

    keymaps = [
      {
        mode = "n";
        key = "<tab>";
        action = "<C-w>w";
        options.desc = "切换分屏";
      }
      {
        mode = "n";
        key = "<leader>r";
        action = "<C-r>";
        options.desc = "重做";
      }
    ];

    # 4. 📦 插件
    plugins = {
      nix.enable = true; 
    };

    # 5. 🛠️ Vimscript 逻辑保留 (处理目录自动创建与 Markdown 修复)
    extraConfigVim = ''
      " ==========================================
      " 文件安全与持久化 (目录自动创建逻辑)
      " ==========================================
      let target_undodir = stdpath('state') . '/undo'
      if !isdirectory(target_undodir)
          call mkdir(target_undodir, 'p', 0700)
      endif
      let &undodir = target_undodir

      let target_swapdir = stdpath('state') . '/swap'
      if !isdirectory(target_swapdir)
          call mkdir(target_swapdir, 'p', 0700)
      endif
      let &directory = target_swapdir . '//'

      autocmd FocusGained,BufEnter * checktime

      " ==========================================
      " Markdown 专项优化 
      " ==========================================
      let g:markdown_disable_html = 1
      let g:markdown_exclude_embed = 1
      let g:markdown_disable_flow = 1

      augroup MarkdownErrorKiller
          autocmd!
          autocmd FileType markdown call MarkdownErrorClear()
      augroup END

      function! MarkdownErrorClear()
          highlight link markdownError Normal
          highlight markdownError term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE guifg=NONE guibg=NONE gui=NONE
      endfunction
    '';
  };
}
