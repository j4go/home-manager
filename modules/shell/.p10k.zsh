# =============================================================================
# 🏆 Powerlevel10k - Pure Minimalist (Single-Line Edition)
# -----------------------------------------------------------------------------
# 核心哲学：无背景、无色块、仅在必要时显示信息
# =============================================================================

() {
  emulate -L zsh -o extended_glob
  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  # 1. 布局：单行左侧对齐
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context                   # 仅 SSH 时显示
    dir                       # 极简路径
    vcs                       # 极简 Git
    command_execution_time    # 耗时
    prompt_char               # 提示符 ❯
  )
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()

  # 2. 全局视觉：扁平化
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_BACKGROUND=
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  
  # 紧凑间距
  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR=' '
  typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE=''
  typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE=' '

  # 3. 模块精修

  # [Context] - 仅 SSH 显示 (Pure 风格通常不显示本地用户)
  typeset -g POWERLEVEL9K_CONTEXT_DEFAULT_CONTENT_EXPANSION='' 
  typeset -g POWERLEVEL9K_CONTEXT_REMOTE_FOREGROUND='242' # 灰色
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_VISUAL_IDENTIFIER_EXPANSION=''

  # [Directory] - Pure 风格路径 (蓝色)
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='39' # 经典的 Pure Blue
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='39'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='39'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  
  # ✅ 路径切断逻辑：实现项目感知
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=true
  typeset -g POWERLEVEL9K_DIR_HOME_SUBFOLDER_AS_ROOT=false
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER='(.git|flake.nix|default.nix)'
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=0
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=''

  # [VCS] - Pure 风格 Git (灰色/紫色)
  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='242'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='242'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='242'
  # 仅保留最基础符号
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=' '
  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_EXPANSION=''
  # 状态符号对标 Pure 原作
  typeset -g POWERLEVEL9K_VCS_COMMITS_AHEAD_THEN_BEHIND=true
  typeset -g POWERLEVEL9K_VCS_AHEAD_ICON='⇡'
  typeset -g POWERLEVEL9K_VCS_BEHIND_ICON='⇣'

  # [Character] - 提示符 (Pure 标志性的 ❯)
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_FOREGROUND='76' # 绿色
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_FOREGROUND='196' # 红色
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_VIINS_CONTENT_EXPANSION='❯'

  # [Command Duration] - 耗时 (黄色)
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='226'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PREFIX=''

  # 4. 行为控制
  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=false # ✅ 强制单行
  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=always
  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
}
