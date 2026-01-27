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
      nightfox-nvim  # 🎨 包含 carbonfox, nightfox, duskfox 等多种风格
    ];

    # 🚀 推荐：使用 Lua 进行现代插件配置
    initLua = ''
      -- 1. Nightfox 配置
      require('nightfox').setup({
        options = {
          -- 样式微调，确保高对比度
          transparent = false,     -- 如果需要背景透明，设为 true
          terminal_colors = true, 
          styles = {
            comments = "italic",   -- 注释使用斜体，保持 Tomorrow 风格的优雅
            keywords = "bold",     -- 关键字加粗
            functions = "none",
          },
        },
      })

      -- 2. 应用主题 (carbonfox 是最接近 Tomorrow Night Bright 的版本)
      vim.cmd.colorscheme "carbonfox"
    '';

    # ⚙️ 核心配置
    extraConfig = ''
      " ==========================================
      " 基础核心 (Neovim 默认已开启 nocompatible 等多项设置)
      " ==========================================
      syntax on
      filetype plugin indent on

      " ==========================================
      " 性能与剪切板 (极致性能模式)
      " ==========================================
      " unnamed:     使用 * 寄存器 (鼠标中键)
      " unnamedplus: 使用 + 寄存器 (系统剪切板 Ctrl+C/V)
      " 开启后，y 就会自动复制到系统，p 就会自动从系统粘贴
      set clipboard^=unnamed,unnamedplus      

      " ==========================================
      " 快捷键映射
      " ==========================================
      let mapleader=";"
      set timeoutlen=500

      " 分屏切换
      nnoremap <tab> <C-w>w

      " 重做
      nnoremap <Leader>r <C-r>

      " ==========================================
      " 排版与缩进
      " ==========================================
      set tabstop=4
      set softtabstop=4
      set shiftwidth=4
      set expandtab
      set autoindent
      set list listchars=tab:▸\ 

      " ==========================================
      " 文件安全与持久化 (遵循 XDG 标准)
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
      " 搜索与补全
      " ==========================================
      set wildmenu
      set path+=**
      set encoding=utf-8
      set fileencodings=utf-8,gb18030,latin1,gbk
      
      " 高亮搜索结果，并在输入时实时跳转
      set hlsearch
      set incsearch

      " ==========================================
      " Markdown 专项优化 (保留原逻辑)
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
      " 界面与体验
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
      " 换行行为
      " ==========================================
      set wrap
      set linebreak
      set textwidth=0
    '';
  };
}
