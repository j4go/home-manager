{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;     # 设置 $EDITOR
    viAlias = true;           # 输入 vi 启动 neovim
    vimAlias = true;          # 输入 vim 启动 neovim
    
    # 📦 插件管理：引入现代主题与基础插件
    plugins = with pkgs.vimPlugins; [
      vim-nix                 # Nix 语言高亮
      tokyonight-nvim         # 🎨 业界推荐：现代、护眼、高对比度主题
    ];

    # ⚙️ 核心配置
    extraConfig = ''
      " ==========================================
      " 1. 基础核心 (Neovim 默认已开启 nocompatible 等多项设置)
      " ==========================================
      syntax on
      filetype plugin indent on

      " ==========================================
      " 2. 性能与剪切板 (极致性能模式)
      " ==========================================
      " 🔴 彻底禁用系统剪切板集成，避免 X11/Wayland 通信延迟
      set clipboard=
      
      " 映射说明：
      " 由于切断了系统剪切板，<Leader><Leader>y 等逻辑已移除。
      " 现在复制粘贴仅在 Neovim 内部寄存器生效，速度最快。

      " ==========================================
      " 3. 主题设置 (Tokyo Night)
      " ==========================================
      if (has('termguicolors'))
        set termguicolors
      endif
      
      " 设置主题风格：storm, night(推荐), moon, day
      let g:tokyonight_style = "night"
      let g:tokyonight_italic_functions = 1
      
      try
        colorscheme tokyonight
      catch
        colorscheme default
      endtry

      " ==========================================
      " 4. 快捷键映射
      " ==========================================
      let mapleader=";"
      set timeoutlen=500

      " 分屏切换
      nnoremap <tab> <C-w>w

      " 重做
      nnoremap <Leader>r <C-r>

      " ==========================================
      " 5. 排版与缩进
      " ==========================================
      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
      set expandtab
      set autoindent
      set list listchars=tab:▸\ 

      " ==========================================
      " 6. 文件安全与持久化 (遵循 XDG 标准)
      " ==========================================
      " 🚀 优化：Neovim 推荐将数据放在 ~/.local/state/nvim (或 stdpath('state'))
      
      set undofile
      " 自动创建 undo 目录
      let target_undodir = stdpath('state') . '/undo'
      if !isdirectory(target_undodir)
          call mkdir(target_undodir, 'p', 0700)
      endif
      let &undodir = target_undodir

      set swapfile
      " 自动创建 swap 目录
      let target_swapdir = stdpath('state') . '/swap'
      if !isdirectory(target_swapdir)
          call mkdir(target_swapdir, 'p', 0700)
      endif
      " // 结尾表示使用绝对路径生成文件名
      let &directory = target_swapdir . '//'

      set nobackup
      set autoread
      autocmd FocusGained,BufEnter * checktime

      " ==========================================
      " 7. 搜索与补全
      " ==========================================
      set wildmenu
      set path+=**
      set encoding=utf-8
      set fileencodings=utf-8,gb18030,latin1,gbk
      
      " 高亮搜索结果，并在输入时实时跳转
      set hlsearch
      set incsearch

      " ==========================================
      " 8. Markdown 专项优化 (保留原逻辑)
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

      " ==========================================
      " 9. 界面与体验
      " ==========================================
      set sidescroll=1
      set laststatus=2
      set backspace=indent,eol,start
      set history=10000
      set number
      set ruler
      set cursorline
      set noerrorbells

      " ==========================================
      " 10. 换行行为
      " ==========================================
      set wrap
      set linebreak
      set textwidth=0
    '';
  };
}
