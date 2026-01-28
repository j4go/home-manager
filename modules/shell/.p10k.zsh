# =============================================================================
# 🚀 Powerlevel10k - Starship Clone Edition
# -----------------------------------------------------------------------------
# 目标：完全对标 Starship 配置文件，实现“无缝切换”体验
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # -------------------------------------------------------------------------
  # 1. 核心布局 (完全对标 Starship format)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                 # 用户名 @ 主机名 (仅 SSH)
    dir                     # 目录
    vcs                     # Git 分支与状态
    nix_shell               # Nix Shell
    command_execution_time  # 执行耗时
    prompt_char             # ➜ 提示符
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=() # 保持右侧清空

  # -------------------------------------------------------------------------
  # 2. 全局扁平化样式 (No Background, No Separators)
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  
  # 间距微调
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=''
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '

  # -------------------------------------------------------------------------
  # 3. 模块级精修
  # -------------------------------------------------------------------------

  # [Context] - 模拟 Starship 的 username + hostname (ssh_only)
  # 逻辑：非 SSH 且非 Root 时隐藏
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='' 
  # SSH 或 Root 时的样式 (Starship: bold #ffaf00)
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='214' # 亮橙色
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='214'
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_SUDO_FOREGROUND='214'
  # 格式：user @ host
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n @ %m'
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION='' # 禁用图标

  # [Directory] - 目录 (Starship: bold cyan, truncation_length = 2)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='14' # Cyan
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='14'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='14'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  typeset -g POWERLEVEL9K_DIR_VISUAL_IDENTIFIER_EXPANSION='' # 禁用文件夹图标
  # 缩写策略：保留最后 2 级目录
  typeset -g POWERLEVEL9K_DIR_SHORTEN_STRATEGY=truncate_to_last
  typeset -g POWERLEVEL9K_DIR_SHORTEN_DIR_LENGTH=2
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  
  # [VCS] - Git (Starship: bold purple)
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='13'    # Purple/Magenta
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='13'
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION='' # 仅保留 branch_icon
  
  # Git 状态符号对标 Starship
  typeset -g POWERLEVEL9K_VCS_CLEAN_PPT_BEFORE_ICON=' '
  typeset -g POWERLEVEL9K_VCS_CLEAN_CONTENT_EXPANSION='${P9K_CONTENT} %F{green}✓%f'
  # 当有改动时显示红色 (Starship 逻辑)
  typeset -g POWERLEVEL9K_VCS_MODIFIED_PPT_BEFORE_ICON=' '

  # [Character] - ➜ (对标 Starship character 模块)
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='green'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='red'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='➜'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='✖'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_LEFT_WHITESPACE=''

  # [Nix Shell] - ❄️ (nix-shell) (Starship: bold blue)
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND='12' # Blue
  typeset -g POWERLEVEL9K_NIX_SHELL_VISUAL_IDENTIFIER_EXPANSION='❄️ '
  typeset -g POWERLEVEL9K_NIX_SHELL_CONTENT_EXPANSION='(nix-shell)'

  # [Command Duration] - took 10s (Starship: dim white)
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=2
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='246' # Dim grey
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX='took '

  # -------------------------------------------------------------------------
  # 4. 环境控制
  # -------------------------------------------------------------------------
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
  
  # 禁用所有默认图标，只保留我们显式定义的
  typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION=''
}
